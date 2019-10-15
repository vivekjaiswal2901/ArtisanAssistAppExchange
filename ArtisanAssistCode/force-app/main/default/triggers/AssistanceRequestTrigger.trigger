/**
 * Artisan Assistance trigger to detect when a customer user creates or updates an Assistance Request in a way
 * which needs replication to the Artisan Salesforce org.  Platform events are published for all records which
 * need data replication.  Delete and undelete are ignored and the data in the Artisan org is unaffected.
 * @author Richard Clarke
 * @date 24/07/2019
 */
trigger AssistanceRequestTrigger on Assistance_Request__c (before insert, after insert, before update, after update) {
    if ( Trigger.isInsert ) {
        // Inserting
        try {
            if ( Trigger.isBefore ) {
//system.debug('*** In AssistanceRequestTrigger before insert');
                // Before insert
                for ( Assistance_Request__c req : Trigger.new ){
                     // Set sync status to pending as all inserted requests are sent to Artisan on creation regardless of status
                    req.Sync_Details__c = '';
                    req.Sync_Status__c = 'Sync pending';
                    
                    // Set phase based on stage name
                    req.Phase__c = AssistanceRequestReplication.PhaseFromStageName( req.Stage_Name__c, req.Prior_Stage_Name__c );
                }
            } else {
//system.debug('*** In AssistanceRequestTrigger after insert');
                // After insert - enqueue callout for all records to replicate data
		        Set<Id> insertedIds = new Set<Id>();
                for ( Assistance_Request__c req : Trigger.new ){
                    insertedIds.add(req.Id);
                }
                System.enqueueJob(new AssistanceRequestReplication( insertedIds, null ));
            }
        } catch (Exception e) {
            Logutils.log(e, 'Enqueuing data for replication to Artisan in AssistanceRequestTrigger due to inserted Requests for Assistance records failed');
        }
    } else {
        // Updating
        try {
            if ( Trigger.isBefore ) {
//system.debug('*** In AssistanceRequestTrigger before update');
				// Before update
                for ( Id updatedRequestId : Trigger.newMap.keySet() ){
                    // Get the before and after records to compare
                    Assistance_Request__c reqBeforeUpdate = Trigger.oldMap.get( updatedRequestId );
                    Assistance_Request__c reqAfterUpdate = Trigger.newMap.get( updatedRequestId );
                    
                    // Check to see if the customer has made a change
                    if ( AssistanceRequestReplication.EventPublicationNeeded(reqBeforeUpdate, reqAfterUpdate) ) {
//system.debug('*** In AssistanceRequestTrigger before update setting sync to Sync pending');
                         // Set the sync status to Sync pending and clear the prior sync details as a sync is going to be triggered
                        reqAfterUpdate.Sync_Status__c = 'Sync pending';
                        reqAfterUpdate.Sync_Details__c = '';
                    }
                 
                    // Adjust the stage/prior stage depending on the number of open questions which is tracked in a summary rollup count field
                    if (( reqBeforeUpdate.Open_Question_Count__c == 0 ) && ( reqAfterUpdate.Open_Question_Count__c > 0 )){
//system.debug('*** In AssistanceRequestTrigger before update setting Stage_Name__c to Waiting for Clarification');
                        // Move to Waiting for Clarification
                        reqAfterUpdate.Stage_Name__c = 'Waiting for Clarification';
                    } else 
                    if (( reqBeforeUpdate.Open_Question_Count__c > 0 ) && ( reqAfterUpdate.Open_Question_Count__c == 0 )){
                        // Move away from Waiting for Clarification
                        if ( String.isBlank(reqAfterUpdate.Prior_Stage_Name__c )) {
//system.debug('*** In AssistanceRequestTrigger before update setting Stage_Name__c to Drafting');
	                        reqAfterUpdate.Stage_Name__c = 'Drafting';
                        } else {
//system.debug('*** In AssistanceRequestTrigger before update setting Stage_Name__c to prior stage [' + reqAfterUpdate.Prior_Stage_Name__c + ']');
                        	reqAfterUpdate.Stage_Name__c = reqAfterUpdate.Prior_Stage_Name__c;
                        }
                    }

                    // If the stage name has changed to something other than Waiting for Clarification capture the prior stage name
                    if ( reqBeforeUpdate.Stage_Name__c != reqAfterUpdate.Stage_Name__c ) {
                        reqAfterUpdate.Prior_Stage_Name__c = reqBeforeUpdate.Stage_Name__c;
//system.debug('*** In AssistanceRequestTrigger before update setting Prior_Stage_Name__c to stage before update [' + reqBeforeUpdate.Stage_Name__c + ']');
                    }
                    
                    // Set phase based on stage name
                    reqAfterUpdate.Phase__c = AssistanceRequestReplication.PhaseFromStageName( reqAfterUpdate.Stage_Name__c, reqAfterUpdate.Prior_Stage_Name__c );
                }
            } else {
//system.debug('*** In AssistanceRequestTrigger after update');
                // After update - enqueue all records where the customer has made changes which need replicating
        		Set<Id> updatedIds = new Set<Id>();
                for ( Id updatedRequestId : Trigger.newMap.keySet() ){
                    // Get the before and after records to compare
                    Assistance_Request__c reqBeforeUpdate = Trigger.oldMap.get( updatedRequestId );
                    Assistance_Request__c reqAfterUpdate = Trigger.newMap.get( updatedRequestId );
                    
                    // Check to see if the customer has made a change
                    if ( AssistanceRequestReplication.EventPublicationNeeded(reqBeforeUpdate, reqAfterUpdate) ) {
                        updatedIds.add(reqAfterUpdate.Id);
//system.debug('*** In AssistanceRequestTrigger after update flagging request for replication Id [' + reqAfterUpdate.Id + ']');
                    }
                }
                if ( updatedIds.size() > 0 ){
//system.debug('*** In AssistanceRequestTrigger after update enqueing requests for replication [' + updatedIds + ']');
                	System.enqueueJob(new AssistanceRequestReplication( null, updatedIds ));
                }
            }
        } catch (Exception e) {
            Logutils.log(e, 'Enqueuing data for replication to Artisan in AssistanceRequestTrigger due to updated Requests for Assistance records failed');
        }
    }
}