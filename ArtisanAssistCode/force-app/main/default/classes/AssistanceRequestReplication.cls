/**
 * Artisan Assist Request Replication Support using a queueable class enqueued from the trigger
 * 
 * The current implementation does callouts for each record in two sets which could in some cases exceed callout limits
 * A future evolution would be to decide how many requests can be processed in one queued execution and chain here to
 * future process excess Ids by passing the left over Ids to the next queueable run.
 * 
 * @author Richard Clarke
 * @date 08/08/2019
 */
public without sharing class AssistanceRequestReplication implements Queueable, Database.AllowsCallouts {
    
    // Hold the Id of the Assistance Request which should be replicated
    Set<Id> insertedIds;
    Set<Id> updatedIds;

    // In constructor capture the Id for which the polling should be done when execute is called
    public AssistanceRequestReplication( Set<Id> replicationInsertedIds, Set<Id> replicationUpdatedIds ) {
        this.insertedIds = replicationInsertedIds;
        this.updatedIds = replicationUpdatedIds;
    }
    
    // On execute do the callouts
    public void execute(QueueableContext context) {
        if ( insertedIds != null ){
            for ( Id reqId : insertedIds ){
                // Call future method one record at a time in MVP, future release will pass List of all inserted Ids
                ReplicateInsertedRecordToArtisanOrg( reqId );
            }
        }
        
        // Retrieve the updated records and notify Artisan org by calling future method for each
        if ( updatedIds != null ){
            for ( Id reqId : updatedIds ){
                // Call future method one record at a time in MVP, future release will pass List of all inserted Ids
                ReplicateUpdatedRecordToArtisanOrg( reqId );
            }
        }
    }

    // Compare the before and after records in an update context and return true if the customer has made changes which need to be pushed to Artisan
    public static Boolean EventPublicationNeeded( Assistance_Request__c reqBeforeUpdate, Assistance_Request__c reqAfterUpdate) {
        // Compare the fields which the Artisan org cares about which can be updated in the customer org
        if (( reqBeforeUpdate.Stage_Name__c != reqAfterUpdate.Stage_Name__c )
             || ( reqBeforeUpdate.Title__c != reqAfterUpdate.Title__c )
             || ( reqBeforeUpdate.Description__c != reqAfterUpdate.Description__c )
             || ( reqBeforeUpdate.Success_Criteria__c != reqAfterUpdate.Success_Criteria__c )
             || ( reqBeforeUpdate.Urgency__c != reqAfterUpdate.Urgency__c )
             || ( reqBeforeUpdate.Date_Required__c != reqAfterUpdate.Date_Required__c )
             || ( reqBeforeUpdate.Environment__c != reqAfterUpdate.Environment__c )
             || ( reqBeforeUpdate.Login_Access__c != reqAfterUpdate.Login_Access__c )
             || ( reqBeforeUpdate.Production_Deployment__c != reqAfterUpdate.Production_Deployment__c )
             || ( reqBeforeUpdate.Sandbox_Name__c != reqAfterUpdate.Sandbox_Name__c )
             || ( reqBeforeUpdate.Salesforce_Product__c != reqAfterUpdate.Salesforce_Product__c )
             || ( reqBeforeUpdate.Preferred_Resource_Location__c != reqAfterUpdate.Preferred_Resource_Location__c )
             || ( reqBeforeUpdate.Preferred_Billing_Currency__c != reqAfterUpdate.Preferred_Billing_Currency__c )
             || ( reqBeforeUpdate.Preferred_Timezone__c != reqAfterUpdate.Preferred_Timezone__c )) {
                 return true;
             } else {
                 return false;
             }
    }
    
    // Helper method to set the phase name based on the stage and prior stage.  Phase is implemented as a dependent picklist for each of reporting but is read-only during
    // data entry
    public static String PhaseFromStageName( String currentStageName, String priorStageName ){
        String phaseName = 'Draft';
        String stageName = currentStageName;
        
        // If stage is waiting for clarification set phase based on prior stage
        if ( stageName == 'Waiting for Clarification' ) {
            stageName = priorStageName;
        }
        
        switch on stageName {
            when 'Drafting' {
                phaseName = 'Draft';
            }
            when 'Waiting for Estimation', 'Being Estimated', 'Waiting for Approval' {
                phaseName = 'Estimation';
            }
            when 'Waiting for Development', 'Being Developed' {
                phaseName = 'Development';
            }
            when 'Waiting for Testing', 'Being Tested' {
                phaseName = 'Test';
            }
            when 'Waiting for Deployment', 'Being Deployed' {
                phaseName = 'Deployment';
            }
            when 'Waiting for Acceptance' {
                phaseName = 'Acceptance';
            }
            when 'Accepted as Complete' {
                phaseName = 'Completed';
            }
            when 'Declined','Rejected' {
                phaseName = 'Cancelled';
            }
        }
        return phaseName;
    }
    
    // Retrieve the inserted record and notify the Artisan org by calling the REST API
    public static void ReplicateInsertedRecordToArtisanOrg( Id reqId ){
        try {
//system.debug('*** In ReplicateInsertedRecordToArtisanOrg handling insert of Id [' + reqId + ']');
            // Retrieve the inserted record
            List<Assistance_Request__c> insertedRequests = [
                Select Id, Name, Stage_Name__c, Prior_Stage_Name__c, Title__c, Description__c, Success_Criteria__c, Phase__c, 
        			Urgency__c, Date_Required__c, Environment__c, Login_Access__c, Production_Deployment__c, Sandbox_Name__c, Salesforce_Product__c,
        			Preferred_Resource_Location__c, Preferred_Billing_Currency__c, Preferred_Timezone__c, CreatedById, CreatedBy.Title, CreatedBy.FirstName,
        			CreatedBy.LastName, CreatedBy.Email, CreatedBy.Phone, CreatedBy.MobilePhone, CreatedBy.Street, CreatedBy.City, CreatedBy.State, CreatedBy.Postalcode,
        			CreatedBy.Country 
                from Assistance_Request__c READONLY 
                where Id = :reqId limit 1];
            if ( insertedRequests.size() == 0 ){
                throw new Utils.DataException('The inserted Assistance Request with Id=[' + reqId + '] cannot be found');
            } else {
                // Setup the date required so we can format using GMT not the current user timezone
                String formattedDateRequired = null; // default as optional field
                if ( insertedRequests[0].Date_Required__c != null ){
	                Datetime dateRequired = Datetime.newInstanceGmt(insertedRequests[0].Date_Required__c, Time.newInstance(0,0,0,0));
                    formattedDateRequired = dateRequired.formatGmt('yyyy-MM-dd');
                }
                // Do the callout to the Artisan REST API
	            Id caseId = ArtisanRestApiCallouts.insertAssistanceRequest(
        			insertedRequests[0].Id,
                    insertedRequests[0].Name,
        			insertedRequests[0].Stage_Name__c,
                    insertedRequests[0].Prior_Stage_Name__c,
                    insertedRequests[0].Phase__c,
        			insertedRequests[0].Title__c,
        			insertedRequests[0].Description__c,
        			insertedRequests[0].Success_Criteria__c,
        			insertedRequests[0].Urgency__c,
        			formattedDateRequired,
        			insertedRequests[0].Environment__c,
        			insertedRequests[0].Login_Access__c,
        			insertedRequests[0].Production_Deployment__c,
        			insertedRequests[0].Sandbox_Name__c,
        			insertedRequests[0].Salesforce_Product__c,
        			insertedRequests[0].Preferred_Resource_Location__c,
        			insertedRequests[0].Preferred_Billing_Currency__c,
        			insertedRequests[0].Preferred_Timezone__c,
        
        			insertedRequests[0].CreatedById,
        			insertedRequests[0].CreatedBy.Title,
        			insertedRequests[0].CreatedBy.FirstName,
        			insertedRequests[0].CreatedBy.LastName,
        			insertedRequests[0].CreatedBy.Email,
        			insertedRequests[0].CreatedBy.Phone,
        			insertedRequests[0].CreatedBy.MobilePhone,
        			insertedRequests[0].CreatedBy.Street,
        			insertedRequests[0].CreatedBy.City,
        			insertedRequests[0].CreatedBy.State,
        			insertedRequests[0].CreatedBy.Postalcode,
        			insertedRequests[0].CreatedBy.Country );
                
                // Expecting a case id to be returned
                if ( caseId == null ){
// system.debug('*** In ReplicateInsertedRecordToArtisanOrg handling insert of Id [' + reqId + '] and null caseId returned');
                    throw new Utils.IntegrationException('The callout to ArtisanRestApiCallouts.insertAssistanceRequest failed to replicate Assistance Request with Id=[' + reqId + ']');
                } 

//system.debug('*** In ReplicateInsertedRecordToArtisanOrg handling insert of Id [' + reqId + '] and caseId [' + caseId + ']');
                insertedRequests = [
                    Select Id, Sync_Status__c, Sync_Details__c 
                    from Assistance_Request__c 
                    where Id = :reqId limit 1 FOR UPDATE];
                if ( insertedRequests.size() != 1 ){
                    throw new Utils.IntegrationException('The sync success update in ArtisanRestApiCallouts.insertAssistanceRequest failed for Id=[' + reqId + ']');
                } else {
                    // Update the record to indicate the sync succeeded
                    insertedRequests[0].Sync_Status__c = 'Sync successful';
                    insertedRequests[0].Sync_Details__c = 'Artisan Case Id=[' + caseId + ']';
                    database.update(insertedRequests[0],false);
                }
            }
        } catch (Exception e) {
        	Logutils.log(e, 'Failed to notify Artisan org during processing inserted Assistance Request [' + reqId + ']');
// system.debug('*** In ReplicateInsertedRecordToArtisanOrg exception ' + e.getMessage());
            
            // Update the record to indicate the sync failed
            List<Assistance_Request__c> insertedRequests = [
                Select Id, Sync_Status__c, Sync_Details__c 
                from Assistance_Request__c 
                where Id = :reqId limit 1 FOR UPDATE];
            if ( insertedRequests.size() == 1 ){
// system.debug('*** In ReplicateInsertedRecordToArtisanOrg on exception about to update sync status to failed');
                insertedRequests[0].Sync_Status__c = 'Sync failed';
                insertedRequests[0].Sync_Details__c = e.getMessage().left(255);
                database.update(insertedRequests[0], false);
// system.debug('*** In ReplicateInsertedRecordToArtisanOrg on exception after updating sync status to failed');
            }                    
        }
    }

    // Retrieve the updated record and notify the Artisan org by calling the REST API
    public static void ReplicateUpdatedRecordToArtisanOrg( Id reqId ){
        try {
//system.debug('*** In AssistanceRequestHandler.ReplicateUpdatedRecordToArtisanOrg handling insert of Id [' + reqId + ']');
            // Retrieve the inserted record
            List<Assistance_Request__c> updatedRequests = [
                Select Id, Name, Stage_Name__c, Prior_Stage_Name__c, Title__c, Description__c, Success_Criteria__c, Phase__c, 
        			Urgency__c, Date_Required__c, Environment__c, Login_Access__c, Production_Deployment__c, Sandbox_Name__c, Salesforce_Product__c,
        			Preferred_Resource_Location__c, Preferred_Billing_Currency__c, Preferred_Timezone__c
				from Assistance_Request__c READONLY 
				where Id = :reqId limit 1];
            if ( updatedRequests.size() == 0 ){
                throw new Utils.DataException('The updated Assistance Request with Id=[' + reqId + '] cannot be found');
            } else {
                // Setup the date required so we can format using GMT not the current user timezone
                String formattedDateRequired = null; // default as optional field
                if ( updatedRequests[0].Date_Required__c != null ){
	                Datetime dateRequired = Datetime.newInstanceGmt(updatedRequests[0].Date_Required__c, Time.newInstance(0,0,0,0));
                    formattedDateRequired = dateRequired.formatGmt('yyyy-MM-dd');
                }

                // Do the callout to the Artisan REST API
	            Id caseId = ArtisanRestApiCallouts.updateAssistanceRequest(
        			updatedRequests[0].Id,
                    updatedRequests[0].Name,
        			updatedRequests[0].Stage_Name__c,
                    updatedRequests[0].Prior_Stage_Name__c,
                    updatedRequests[0].Phase__c,
        			updatedRequests[0].Title__c,
        			updatedRequests[0].Description__c,
        			updatedRequests[0].Success_Criteria__c,
        			updatedRequests[0].Urgency__c,
        			formattedDateRequired,
        			updatedRequests[0].Environment__c,
        			updatedRequests[0].Login_Access__c,
        			updatedRequests[0].Production_Deployment__c,
        			updatedRequests[0].Sandbox_Name__c,
        			updatedRequests[0].Salesforce_Product__c,
        			updatedRequests[0].Preferred_Resource_Location__c,
        			updatedRequests[0].Preferred_Billing_Currency__c,
        			updatedRequests[0].Preferred_Timezone__c );
                
                // Expecting a case id to be returned
                if ( caseId == null ){
// system.debug('*** In AssistanceRequestHandler.ReplicateUpdatedRecordToArtisanOrg handling update of Id [' + reqId + '] and null caseId returned');
                    throw new Utils.IntegrationException('The callout to ArtisanRestApiCallouts.updateAssistanceRequest failed to replicate Assistance Request with Id=[' + reqId + ']');
                } 

//system.debug('*** In AssistanceRequestHandler.ReplicateUpdatedRecordToArtisanOrg handling update of Id [' + reqId + '] and caseId [' + caseId + ']');
                updatedRequests = [
                    Select Id, Sync_Status__c, Sync_Details__c 
                    from Assistance_Request__c 
                    where Id = :reqId limit 1 FOR UPDATE];
                if ( updatedRequests.size() != 1 ){
                    throw new Utils.IntegrationException('The sync success update in ArtisanRestApiCallouts.updateAssistanceRequest failed for Id=[' + reqId + ']');
                } else {
                    // Update the record to indicate the sync succeeded
                    updatedRequests[0].Sync_Status__c = 'Sync successful';
                    updatedRequests[0].Sync_Details__c = 'Artisan Case Id=[' + caseId + ']';
                    database.update(updatedRequests[0],false);
                }
            }
        } catch (Exception e) {
        	Logutils.log(e, 'Failed to notify Artisan org during processing updated Assistance Request [' + reqId + ']');
// system.debug('*** In AssistanceRequestHandler.ReplicateUpdatedRecordToArtisanOrg exception ' + e.getMessage());
            
            // Update the record to indicate the sync failed
            List<Assistance_Request__c> updatedRequests = [
                Select Id, Sync_Status__c, Sync_Details__c 
                from Assistance_Request__c 
                where Id = :reqId limit 1 FOR UPDATE];
            if ( updatedRequests.size() == 1 ){
// system.debug('*** In AssistanceRequestHandler.ReplicateUpdatedRecordToArtisanOrg on exception about to update sync status to failed');
                updatedRequests[0].Sync_Status__c = 'Sync failed';
                updatedRequests[0].Sync_Details__c = e.getMessage().left(255);
                database.update(updatedRequests[0], false);
// system.debug('*** In AssistanceRequestHandler.ReplicateUpdatedRecordToArtisanOrg on exception after updating sync status to failed');
            }                    
        }
    }
}