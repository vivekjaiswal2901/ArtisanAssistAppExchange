/**
 * Artisan Assist Question and Answer Replication Support using a queueable class enqueued from the trigger
 * 
 * The current implementation does callouts for each record in two sets which could in some cases exceed callout limits
 * A future evolution would be to decide how many requests can be processed in one queued execution and chain here to
 * future process excess Ids by passing the left over Ids to the next queueable run.
 * 
 * @author Richard Clarke
 * @date 08/08/2019
 */
public without sharing class QuestionAnswerReplication implements Queueable, Database.AllowsCallouts {
    
    // Hold the Id of the Assistance Request which should be replicated
    Set<Id> insertedIds;
    Set<Id> updatedIds;

    // In constructor capture the Id for which the polling should be done when execute is called
    public QuestionAnswerReplication( Set<Id> replicationInsertedIds, Set<Id> replicationUpdatedIds ) {
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
        if ( updatedIds != null ) {
            for ( Id reqId : updatedIds ){
                // Call future method one record at a time in MVP, future release will pass List of all inserted Ids
                ReplicateUpdatedRecordToArtisanOrg( reqId );
            }
        }
    }
    
    // Compare the before and after records in an update context and return true if the customer has made changes which need to be pushed to Artisan
    public static Boolean EventPublicationNeeded( Question_Answer__c qaBeforeUpdate, Question_Answer__c qaAfterUpdate) {
        // Compare the fields which the Artisan org cares about which can be updated in the customer org
        if ( qaBeforeUpdate.RecordTypeId == Utils.GetCustomerQuestionAnswerRecordTypeId()){
            // Customer asked question so customer can only change the question
            if ( qaBeforeUpdate.Question__c != qaAfterUpdate.Question__c ){
                 return true;
             } else {
                 return false;
             }
        } else {
            // Artisan asked question so customer can only change the answer
            if ( qaBeforeUpdate.Answer__c != qaAfterUpdate.Answer__c ) {
                 return true;
             } else {
                 return false;
             }
        }
    }
    
    // Retrieve the inserted record and notify the Artisan org by calling the REST API
    public static void ReplicateInsertedRecordToArtisanOrg( Id qaId ){
        try {
// system.debug('*** In QuestionAnswerReplication.ReplicateInsertedRecordToArtisanOrg handling insert of Id [' + qaId + ']');
            // Retrieve the inserted record
            List<Question_Answer__c> insertedQuestions = [
                Select Assistance_Request_Id__c, Id, Name, Question__c, Asked_by_Name__c, Asked_by_Email__c, Asked_by_Phone__c 
                from Question_Answer__c READONLY 
                where Id = :qaId limit 1];
            if ( insertedQuestions.size() == 0 ){
                throw new Utils.DataException('The inserted Question Answer with Id=[' + qaId + '] cannot be found');
            } else {
                // Do the callout to the Artisan REST API
	            Id artisanQAId = ArtisanRestApiCallouts.insertQuestionAnswer(
                    insertedQuestions[0].Assistance_Request_Id__c,
        			insertedQuestions[0].Id,
                    insertedQuestions[0].Name,
        			insertedQuestions[0].Question__c,
                    insertedQuestions[0].Asked_by_Name__c,
        			insertedQuestions[0].Asked_by_Email__c,
        			insertedQuestions[0].Asked_by_Phone__c );
                
                // Expecting a case id to be returned
                if ( artisanQAId == null ){
// system.debug('*** In QuestionAnswerReplication.ReplicateInsertedRecordToArtisanOrg handling insert of Id [' + qaId + '] and null artisanQAId returned');
                    throw new Utils.IntegrationException('The callout to ArtisanRestApiCallouts.createQuestionAndAnswer failed to replicate Question Answer with Id=[' + qaId + ']');
                } 

// system.debug('*** In QuestionAnswerReplication.ReplicateInsertedRecordToArtisanOrg handling insert of Id [' + qaId + '] and artisanQAId [' + artisanQAId + ']');
                insertedQuestions = [
                    Select Id, Sync_Status__c, Sync_Details__c 
                    from Question_Answer__c 
                    where Id = :qaId limit 1 FOR UPDATE];
                if ( insertedQuestions.size() != 1 ){
                    throw new Utils.IntegrationException('The sync success update in ArtisanRestApiCallouts.createQuestionAndAnswer failed for Id=[' + qaId + ']');
                } else {
                    // Update the record to indicate the sync succeeded
                    insertedQuestions[0].Sync_Status__c = 'Sync successful';
                    insertedQuestions[0].Sync_Details__c = 'Artisan Q&A Id=[' + artisanQAId + ']';
                    database.update(insertedQuestions[0],false);
                }
            }
        } catch (Exception e) {
        	Logutils.log(e, 'Failed to notify Artisan org during processing inserted Question Answer [' + qaId + ']');
// system.debug('*** In QuestionAnswerReplication.ReplicateInsertedRecordToArtisanOrg exception ' + e.getMessage());
            
            // Update the record to indicate the sync failed
            List<Question_Answer__c> insertedQuestions = [
                Select Id, Sync_Status__c, Sync_Details__c 
                from Question_Answer__c 
                where Id = :qaId limit 1 FOR UPDATE];
            if ( insertedQuestions.size() == 1 ){
// system.debug('*** In QuestionAnswerReplication.ReplicateInsertedRecordToArtisanOrg on exception about to update sync status to failed');
                insertedQuestions[0].Sync_Status__c = 'Sync failed';
                insertedQuestions[0].Sync_Details__c = e.getMessage().left(255);
                database.update(insertedQuestions[0], false);
// system.debug('*** In QuestionAnswerReplication.ReplicateInsertedRecordToArtisanOrg on exception after updating sync status to failed');
            }                    
        }
    }
    
    // Retrieve the updated record and notify the Artisan org by calling the REST API
    public static void ReplicateUpdatedRecordToArtisanOrg( Id qaId ){
        try {
// system.debug('*** In QuestionAnswerReplication.ReplicateUpdatedRecordToArtisanOrg handling update of Id [' + qaId + ']');
			// Get the record type for a customer asked question as this will control which API is used for the update
	        Id customerQuestionRecordTypeId = Utils.GetCustomerQuestionAnswerRecordTypeId();
            
            // Retrieve the inserted record
            List<Question_Answer__c> updatedQuestions = [
                Select RecordTypeId, Artisan_Question_Answer_Id__c, Id, Name, Question__c, Answer__c, Answered_by_Name__c, Answered_by_Email__c, Answered_by_Phone__c 
				from Question_Answer__c READONLY 
				where Id = :qaId limit 1];
            if ( updatedQuestions.size() == 0 ){
                throw new Utils.DataException('The updated Question Answer with Id=[' + qaId + '] cannot be found');
            } else {
	            String artisanQAId = null;
                if ( updatedQuestions[0].RecordTypeId == customerQuestionRecordTypeId){
                    // Customer asked question being updated by customer so only question can change - call the API
                    artisanQAId = ArtisanRestApiCallouts.updateQuestionAnswer(
        				'', // Artisan_Question_Answer_Id
        				updatedQuestions[0].Id, // Question_Answer_Id
        				'', // Question_Answer_Ref
        				Utils.customerQuestionAnswerRecordTypeAPIName, // Question_Answer_RecordType_Name
       					updatedQuestions[0].Question__c, // Question
       					'', // Answer
        				'', // Answered_by_Name,
        				'', // Answered_by_Email,
                        '' ); // Answered_by_Phone
                
                    // Expecting a question and answer id to be returned
                    if ( artisanQAId == null ){
// system.debug('*** In QuestionAnswerReplication.ReplicateUpdatedRecordToArtisanOrg handling Customer Q&A update of Id [' + qaId + '] and null artisanQAId returned');
                        throw new Utils.IntegrationException('The callout to ArtisanRestApiCallouts.updateQuestionAnswer failed to replicate customer Question with Id=[' + qaId + ']');
                    } 
                } else {
                    // Artisan asked question so only the answer can change and who provided it
                    artisanQAId = ArtisanRestApiCallouts.updateQuestionAnswer(
        				updatedQuestions[0].Artisan_Question_Answer_Id__c, // Artisan_Question_Answer_Id
        				updatedQuestions[0].Id, // Question_Answer_Id
        				updatedQuestions[0].Name, // Question_Answer_Ref
        				Utils.artisanQuestionAnswerRecordTypeAPIName, // Question_Answer_RecordType_Name
       					'', // Question
       					updatedQuestions[0].Answer__c, // Answer
        				updatedQuestions[0].Answered_by_Name__c, // Answered_by_Name,
        				updatedQuestions[0].Answered_by_Email__c, // Answered_by_Email,
                        updatedQuestions[0].Answered_by_Phone__c );  // Answered_by_Phone
                
                    // Expecting a question and answer id to be returned
                    if ( artisanQAId == null ){
// system.debug('*** In QuestionAnswerReplication.ReplicateUpdatedRecordToArtisanOrg handling Artisan Q&A update of Id [' + qaId + '] and null artisanQAId returned');
                        throw new Utils.IntegrationException('The callout to ArtisanRestApiCallouts.updateQuestionAnswer failed to replicate Artisan Question with Id=[' + qaId + ']');
                    } 
                }

// system.debug('*** In QuestionAnswerReplication.ReplicateUpdatedRecordToArtisanOrg handling update of Id [' + qaId + '] and artisanQAId [' + artisanQAId + ']');
                updatedQuestions = [
                    Select Id, Sync_Status__c, Sync_Details__c 
                    from Question_Answer__c 
                    where Id = :qaId limit 1 FOR UPDATE];
                if ( updatedQuestions.size() != 1 ){
                    throw new Utils.IntegrationException('The sync success update in ArtisanRestApiCallouts.updateArtisanQuestion failed for Id=[' + qaId + ']');
                } else {
                    // Update the record to indicate the sync succeeded
                    updatedQuestions[0].Sync_Status__c = 'Sync successful';
                    updatedQuestions[0].Sync_Details__c = 'Artisan Q&A Id=[' + artisanQAId + ']';
                    database.update(updatedQuestions[0],false);
                }
            }  
        } catch (Exception e) {
        	Logutils.log(e, 'Failed to notify Artisan org during processing updated Question Answer [' + qaId + ']');
// system.debug('*** In QuestionAnswerReplication.ReplicateUpdatedRecordToArtisanOrg exception ' + e.getMessage());
            
            // Update the record to indicate the sync failed
            List<Question_Answer__c> insertedQuestions = [
                Select Id, Sync_Status__c, Sync_Details__c 
                from Question_Answer__c 
                where Id = :qaId limit 1 FOR UPDATE];
            if ( insertedQuestions.size() == 1 ){
// system.debug('*** In QuestionAnswerReplication.ReplicateUpdatedRecordToArtisanOrg on exception about to update sync status to failed');
                insertedQuestions[0].Sync_Status__c = 'Sync failed';
                insertedQuestions[0].Sync_Details__c = e.getMessage().left(255);
                database.update(insertedQuestions[0], false);
// system.debug('*** In QuestionAnswerReplication.ReplicateUpdatedRecordToArtisanOrg on exception after updating sync status to failed');
            }                    
        }
    }
}