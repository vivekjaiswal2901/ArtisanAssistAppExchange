/**
 * Artisan Assistance trigger to detect when a customer user creates or makes changes to an Question and Answer
 * which needs replication to the Artisan Salesforce org.  Platform events are published for all records which
 * need data replication.  Delete and undelete are ignored as the data in the Artisan org is unaffected.
 * @author Richard Clarke
 * @date 24/07/2019
 */
trigger QuestionAnswerTrigger on Question_Answer__c (before insert, after insert, before update, after update) {
    if ( Trigger.isInsert ) {
        // Inserting
        try {
            if ( Trigger.isBefore ) {
                // Before insert - retrieve current user phone information as this is not in UserInfo
                List<User> currentUser = [select Id, Phone, MobilePhone from User readonly where Id = :UserInfo.getUserId() limit 1];

                for ( Question_Answer__c qa : Trigger.new ){
                     // Set sync status to pending as all inserted qauests are sent to Artisan on creation regardless of status
                    qa.Sync_Details__c = '';
                    qa.Sync_Status__c = 'Sync pending';
                    
                    // Set asked by fields on insert if not already specified
                    if ( String.isBlank(qa.Asked_by_Name__c) ) {
                        qa.Asked_by_Name__c = UserInfo.getName();
                        qa.Asked_by_Email__c = UserInfo.getUserEmail();
                        if ( currentUser.size() == 1 ){
                            if ( String.isBlank(currentUser[0].Phone) ) {
                                qa.Asked_by_Phone__c = currentUser[0].MobilePhone;
                            } else {
                                qa.Asked_by_Phone__c = currentUser[0].Phone;
                            }	                    
                        }
                    }
                    
                    // Questions asked interactively in the UI don't support entry of the answer as well as a question but both could be provided during data integration
                    qa.IsOpen__c = true;
                    if (( qa.Answer__c != null ) && ( qa.Answer__c.length() > 0 )){
                        qa.IsOpen__c = false;
                    }
                }
            } else {
                // After insert - enqueue callout for all records to replicate data
		        Set<Id> insertedIds = new Set<Id>();
                for ( Question_Answer__c qa : Trigger.new ){
                    insertedIds.add(qa.Id);
                }
                System.enqueueJob(new QuestionAnswerReplication( insertedIds, null ));
            }
        } catch (Exception e) {
            Logutils.log(e, 'Publishing events in QuestionAnswerTrigger due to inserted Question and Answer records failed');
        }
    } else {
        // Updating
        try {
            if ( Trigger.isBefore ) {
				// Before update - retrieve current user phone information as this is not in UserInfo
                List<User> currentUser = [select Id, Phone, MobilePhone from User readonly where Id = :UserInfo.getUserId() limit 1];
                
                for ( Id updatedQuestionId : Trigger.newMap.keySet() ){
                    // Get the before and after records to compare
                    Question_Answer__c qaBeforeUpdate = Trigger.oldMap.get( updatedQuestionId );
                    Question_Answer__c qaAfterUpdate = Trigger.newMap.get( updatedQuestionId );
                    
                    // Check to see if the customer has made a change
                    if ( QuestionAnswerReplication.EventPublicationNeeded(qaBeforeUpdate, qaAfterUpdate) ) {
                        // Set the sync status to Sync pending and clear the prior sync details as a sync is going to be triggered
                        qaAfterUpdate.Sync_Status__c = 'Sync pending';
                        qaAfterUpdate.Sync_Details__c = '';
                        
                        // If answer has just been set capture who provided the answer if not already set
                        if ( String.isBlank(qaBeforeUpdate.Answer__c) && !String.isBlank(qaAfterUpdate.Answer__c) )
                        {
                            if ( String.isBlank(qaAfterUpdate.Answered_by_Name__c) ) {
                                qaAfterUpdate.Answered_by_Name__c = UserInfo.getName();
                                qaAfterUpdate.Answered_by_Email__c = UserInfo.getUserEmail();
                                if ( currentUser.size() == 1 ){
                                    if ( String.isBlank(currentUser[0].Phone) ) {
                                        qaAfterUpdate.Answered_by_Phone__c = currentUser[0].MobilePhone;
                                    } else {
                                        qaAfterUpdate.Answered_by_Phone__c = currentUser[0].Phone;
                                    }	                    
                                }
                            }
                        }
                    }
                    
                    // Questions asked interactively in the UI don't support entry of the answer as well as a question but both could be provided during data integration
                    qaAfterUpdate.IsOpen__c = true;
                    if (( qaAfterUpdate.Answer__c != null ) && ( qaAfterUpdate.Answer__c.length() > 0 )){
                        qaAfterUpdate.IsOpen__c = false;
                    }
                }
            } else {
                // After update - enqueue all records where the customer has made changes which need replicating
        		Set<Id> updatedIds = new Set<Id>();
                for ( Id updatedQuestionId : Trigger.newMap.keySet() ){
                    // Get the before and after records to compare
                    Question_Answer__c qaBeforeUpdate = Trigger.oldMap.get( updatedQuestionId );
                    Question_Answer__c qaAfterUpdate = Trigger.newMap.get( updatedQuestionId );
                    
                    // Check to see if the customer has made a change
                    if ( QuestionAnswerReplication.EventPublicationNeeded(qaBeforeUpdate, qaAfterUpdate) ) {
                        updatedIds.add(qaAfterUpdate.Id);
                    }
                }
                System.enqueueJob(new QuestionAnswerReplication( null, updatedIds ));
            }
        } catch (Exception e) {
            Logutils.log(e, 'Publishing events in QuestionAnswerTrigger due to updated Questions and Answers records failed');
        }
    }
}