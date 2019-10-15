/**
 * Artisan Assistance class to handle testing question and answer object insert/update with supporting trigger and platform event functionality
 *
 * @author Richard Clarke
 * @date 29/07/2019
 */
@isTest
public class QuestionAnswerReplicationTest {

    // Test the handling when a Customer Question and Answer is created then updated and works as it should
    static testMethod void testCustomerQAInsertUpdate_ExpectedBehaviour() {
        // Setup callout mock response to create initial request to parent the Q&A
        string mockRequestResponseBody = '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockRequestResponseBody, responseHeaders));

        // Create a new request for assistance at Waiting for Estimation stage as needs to be active for Q&A
        Assistance_Request__c req = new Assistance_Request__c(
            Description__c = 'I need some help',
            Login_Access__c = 'Yes',
            Preferred_Billing_Currency__c = 'AUD - Australian Dollar',
            Preferred_Resource_Location__c = 'No preference',
            Preferred_Timezone__c = '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            Prior_Stage_Name__c = null,
            Date_Required__c = Date.today().addMonths(1),
            Salesforce_Product__c = 'Sales Cloud',
            Sandbox_Name__c = null,
            Stage_Name__c = 'Waiting for Estimation',
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'Please help me',
            Urgency__c = 'Medium');
        insert req;

        Test.startTest();

         // Setup callout mock response to insert and update the Q&C
        String mockQAResponseBody = '{\"Question_Answer__c.Id\":\"a020p00000Dv7TnAAJ\"}';
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockQAResponseBody, responseHeaders));

        // Insert the customer question
        Question_Answer__c qa = new Question_Answer__c(
            RecordTypeId = Utils.GetCustomerQuestionAnswerRecordTypeId(),
            Assistance_Request_Id__c = req.Id,
            Question__c = 'Why is the estimate so high?');
        insert qa;

        // Check the qa.IsOpen__c and req.Open_Question_Count__c are set correctly
		qa = [
            select Id, Question__c, Answer__c, IsOpen__c, Assistance_Request_Id__r.Open_Question_Count__c
            from Question_Answer__c 
            where Id = :qa.Id 
            limit 1 
            for update][0];
        system.assertEquals(true, qa.IsOpen__c, 'New questions without answers should be flagged as open');
        system.assertEquals(1, qa.Assistance_Request_Id__r.Open_Question_Count__c, 'A new request with a single open question should have a count of 1');

        // Simulate update by Artisan
        qa.Answer__c = 'Because you are asking for complicated changes!';
        qa.Answered_by_Email__c = 'artisan.assistance@pscgroup.com.au';
        qa.Answered_by_Name__c = 'Artisan Assistance Delivery Lead';
        qa.Answered_by_Phone__c = '+61 410 123 123';
        update qa;
            
        // Check the open question counts and flags now an answer has been provided
		qa = [
            select Id, Question__c, Answer__c, IsOpen__c, Assistance_Request_Id__r.Open_Question_Count__c
            from Question_Answer__c 
            where Id = :qa.Id 
            limit 1 
            for update][0];
        system.assertEquals(false, qa.IsOpen__c, 'Questions without answers should not be flagged as open');
        system.assertEquals(0, qa.Assistance_Request_Id__r.Open_Question_Count__c, 'A request without open questions should have a count of 0');
        
        // Update it as the customer
        qa.Question__c = 'Why is the estimate so high and why does it take so long?';
        update qa;

        Test.stopTest();

        // Read back the final outcome
		Question_Answer__c updatedQA = [
            select Id, Name, Question__c, Asked_by_Name__c, Assistance_Request_Id__c, RecordTypeId, Sync_Status__c, Sync_Details__c
            from Question_Answer__c 
            where Id = :qa.Id 
            limit 1][0];

        // Insert trigger should have published an insert and the event subscriber/trigger should have called the API and updated the sync details
        system.assertEquals('Sync successful', updatedQA.Sync_Status__c , 'Expecting the question to be updated reflecting data is in sync');
        system.assertEquals(true, updatedQA.Sync_Details__c.contains('Artisan Q&A Id=['), 'Expecting the sync details to contain the Artisan Q&A Id [' + updatedQA.Sync_Details__c + ']');
    }

    // Test the handling when Question and Answer is created then gets an exception during the replication
    static testMethod void testCustomerQAInsert_ExceptionBehaviour() {
        // Setup callout mock response to create initial request to parent the Q&A
        string mockRequestResponseBody = '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockRequestResponseBody, responseHeaders));

        // Create a new request for assistance at Waiting for Estimation stage as needs to be active for Q&A
        Assistance_Request__c req = new Assistance_Request__c(
            Description__c = 'I need some help',
            Login_Access__c = 'Yes',
            Preferred_Billing_Currency__c = 'AUD - Australian Dollar',
            Preferred_Resource_Location__c = 'No preference',
            Preferred_Timezone__c = '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            Prior_Stage_Name__c = null,
            Date_Required__c = Date.today().addMonths(1),
            Salesforce_Product__c = 'Sales Cloud',
            Sandbox_Name__c = null,
            Stage_Name__c = 'Waiting for Estimation',
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'Please help me',
            Urgency__c = 'Medium');
        insert req;

        Test.startTest();

         // Setup callout mock response to insert and update the Q&C
        String mockQAResponseBody = '{\"Exception\":\"Question is required\"}';
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockQAResponseBody, responseHeaders));

        // Insert the customer question
        Question_Answer__c qa = new Question_Answer__c(
            RecordTypeId = Utils.GetCustomerQuestionAnswerRecordTypeId(),
            Assistance_Request_Id__c = req.Id,
            Question__c = null);
        insert qa;

        Test.stopTest();

        // Read back the final outcome
		Question_Answer__c updatedQA = [
            select Id, Name, Question__c, Asked_by_Name__c, Assistance_Request_Id__c, RecordTypeId, Sync_Status__c, Sync_Details__c
            from Question_Answer__c 
            where Id = :qa.Id 
            limit 1][0];

        // Insert trigger should have published an insert and the event subscriber/trigger should have called the API and updated the sync details
        system.assertEquals( 'Sync failed', updatedQA.Sync_Status__c , 'Expecting the question to be updated reflecting data is in sync' );
        system.assertEquals( true, updatedQA.Sync_Details__c.contains('The callout to ArtisanRestApiCallouts.createQuestionAndAnswer failed to replicate Question Answer with Id'), 'Expecting the sync details to contain the exception [' + updatedQA.Sync_Details__c + ']' );
    }

    // Test the handling when Question and Answer is updated then gets an exception during the replication
    static testMethod void testCustomerQAUpdate_ExceptionBehaviour() {
        // Setup callout mock response to create initial request to parent the Q&A
        string mockRequestResponseBody = '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockRequestResponseBody, responseHeaders));

        // Create a new request for assistance at Waiting for Estimation stage as needs to be active for Q&A
        Assistance_Request__c req = new Assistance_Request__c(
            Description__c = 'I need some help',
            Login_Access__c = 'Yes',
            Preferred_Billing_Currency__c = 'AUD - Australian Dollar',
            Preferred_Resource_Location__c = 'No preference',
            Preferred_Timezone__c = '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            Prior_Stage_Name__c = null,
            Date_Required__c = Date.today().addMonths(1),
            Salesforce_Product__c = 'Sales Cloud',
            Sandbox_Name__c = null,
            Stage_Name__c = 'Waiting for Estimation',
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'Please help me',
            Urgency__c = 'Medium');
        insert req;

         // Setup callout mock response to insert and update the Q&C
        String mockQAResponseBody = '{\"Question_Answer__c.Id\":\"a020p00000Dv7TnAAJ\"}';
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockQAResponseBody, responseHeaders));

        // Insert the customer question
        Question_Answer__c qa = new Question_Answer__c(
            RecordTypeId = Utils.GetCustomerQuestionAnswerRecordTypeId(),
            Assistance_Request_Id__c = req.Id,
            Question__c = 'Why is the estimate so expensive?');
        insert qa;

        Test.startTest();

         // Setup callout mock response to insert and update the Q&C
        String mockExceptionQAResponseBody = '{\"Exception\":\"Question is required\"}';
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockExceptionQAResponseBody, responseHeaders));

        // Insert the customer question
        qa = [select Id, Question__c from Question_Answer__c where Id = : qa.Id][0];
        qa.Question__c = null;
        update qa;

        Test.stopTest();

        // Read back the final outcome
		Question_Answer__c updatedQA = [
            select Id, Name, Question__c, Asked_by_Name__c, Assistance_Request_Id__c, RecordTypeId, Sync_Status__c, Sync_Details__c
            from Question_Answer__c 
            where Id = :qa.Id 
            limit 1][0];

        // Insert trigger should have published an insert and the event subscriber/trigger should have called the API and updated the sync details
        system.assertEquals('Sync failed', updatedQA.Sync_Status__c , 'Expecting the question to be updated reflecting data is in sync');
        system.assertEquals(true, updatedQA.Sync_Details__c.contains('The callout to ArtisanRestApiCallouts.updateQuestionAnswer failed to replicate customer Question with Id'), 'Expecting the sync details to contain the exception [' + updatedQA.Sync_Details__c + ']');
    }

    // Test the handling when an Artisan Question and Answer is created then updated and works as it should
    static testMethod void testArtisanQAInsertUpdate_ExpectedBehaviour() {
        // Setup callout mock response to create initial request to parent the Q&A
        string mockRequestResponseBody = '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockRequestResponseBody, responseHeaders));

        // Create a new request for assistance at Waiting for Estimation stage as needs to be active for Q&A
        Assistance_Request__c req = new Assistance_Request__c(
            Description__c = 'I need some help',
            Login_Access__c = 'Yes',
            Preferred_Billing_Currency__c = 'AUD - Australian Dollar',
            Preferred_Resource_Location__c = 'No preference',
            Preferred_Timezone__c = '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            Prior_Stage_Name__c = null,
            Date_Required__c = Date.today().addMonths(1),
            Salesforce_Product__c = 'Sales Cloud',
            Sandbox_Name__c = null,
            Stage_Name__c = 'Waiting for Estimation',
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'Please help me',
            Urgency__c = 'Medium');
        insert req;

         // Setup callout mock response to insert and update the Q&C
        String mockQAResponseBody = '{\"Question_Answer__c.Id\":\"a020p00000Dv7TnAAJ\"}';
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockQAResponseBody, responseHeaders));

        // Insert the Artisan question (in real use would be created when the polling API receives the data from the Artisan org)
        Question_Answer__c qa = new Question_Answer__c(
            RecordTypeId = Utils.GetArtisanQuestionAnswerRecordTypeId(),
            Artisan_Question_Answer_Id__c = 'a02123123123123',
            Assistance_Request_Id__c = req.Id,
            Question__c = 'How will you decide when this work is complete?');
        insert qa;

        Test.startTest();
            
        // Update it as the customer
		qa = [
            select Id, Answer__c
            from Question_Answer__c 
            where Id = :qa.Id 
            limit 1 
            for update][0];

        // Simulate update by Customer
        qa.Answer__c = 'Salesforce will finally work for me!';
        update qa;

        Test.stopTest();

        // Read back the final outcome
		Question_Answer__c updatedQA = [
            select Id, Name, Question__c, Asked_by_Name__c, Assistance_Request_Id__c, RecordTypeId, Sync_Status__c, Sync_Details__c
            from Question_Answer__c 
            where Id = :qa.Id 
            limit 1][0];

        // Insert trigger should have published an insert and the event subscriber/trigger should have called the API and updated the sync details
        system.assertEquals('Sync successful', updatedQA.Sync_Status__c , 'Expecting the question to be updated reflecting data is in sync');
        system.assertEquals(true, updatedQA.Sync_Details__c.contains('Artisan Q&A Id=['), 'Expecting the sync details to contain the Artisan Q&A Id [' + updatedQA.Sync_Details__c + ']');
    }

    // Test the handling when an Artisan Question and Answer is created then updated and gets an exception via the API on an update
    static testMethod void testArtisanQAInsertUpdate_ExceptionBehaviour() {

        // Setup to support multiple mock responses from different end points        
        Map<String, String> responseHeaders =  new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');

        // Add mock response expected when inserting a case into the Artisan org after inserting an Assistance Request in the customer org
        ArtisanRestApiCalloutsMock calloutMocks = new ArtisanRestApiCalloutsMock( 'POST', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when updating a case into the Artisan org after updating an Assistance Request in the customer org
        calloutMocks.AddMockResponse( 'PUT', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response to insert Q&A
        calloutMocks.AddMockResponse( 'POST', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/', 
                                     200, '{\"Question_Answer__c.Id\":\"a020p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response to fail when updating an Artisan Q&A
        calloutMocks.AddMockResponse( 'PATCH', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/', 
                                     200, '{\"Exception\":\"Answer is required\"}', responseHeaders );
        
        // Quick use of the remove and re-put methods to get coverage in ArtisanRestApiCalloutsMock
        calloutMocks.RemoveMockResponse( 'PATCH', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/');
        calloutMocks.AddMockResponse( 'PATCH', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/', 
                                     200, '{\"Exception\":\"Answer is required\"}', responseHeaders );

        // Set mock response
        Test.setMock(HttpCalloutMock.class, calloutMocks);

        // Create a new request for assistance at Waiting for Estimation stage as needs to be active for Q&A
        Assistance_Request__c req = new Assistance_Request__c(
            Description__c = 'I need some help',
            Login_Access__c = 'Yes',
            Preferred_Billing_Currency__c = 'AUD - Australian Dollar',
            Preferred_Resource_Location__c = 'No preference',
            Preferred_Timezone__c = '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            Prior_Stage_Name__c = null,
            Date_Required__c = Date.today().addMonths(1),
            Salesforce_Product__c = 'Sales Cloud',
            Sandbox_Name__c = null,
            Stage_Name__c = 'Waiting for Estimation',
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'Please help me',
            Urgency__c = 'Medium');
        insert req;

        // Insert the Artisan question (in real use would be created when the polling API receives the data from the Artisan org)
        Question_Answer__c qa = new Question_Answer__c(
            RecordTypeId = Utils.GetArtisanQuestionAnswerRecordTypeId(),
            Artisan_Question_Answer_Id__c = 'a02123123123123',
            Assistance_Request_Id__c = req.Id,
            Question__c = 'How will you decide when this work is complete?');
        insert qa;
            
        // Update it as the customer
		qa = [
            select Id, Answer__c
            from Question_Answer__c 
            where Id = :qa.Id 
            limit 1 
            for update][0];

        // Simulate update by Customer
        qa.Answer__c = 'Salesforce will finally work for me!';
        update qa;

        Test.startTest();
        
        // Update it again to clear the answer which should create an exception as an update to an Artisan asked question must include an answer
        qa.Answer__c = null;
        update qa;

        Test.stopTest();

        // Read back the final outcome
		Question_Answer__c updatedQA = [
            select Id, Name, Question__c, Answer__c, Asked_by_Name__c, Assistance_Request_Id__c, RecordTypeId, Sync_Status__c, Sync_Details__c
            from Question_Answer__c 
            where Id = :qa.Id 
            limit 1][0];

        // Insert trigger should have published an insert and the event subscriber/trigger should have called the API and updated the sync details
        system.assertEquals(null, updatedQA.Answer__c, 'The question should have a null answer');
        system.assertEquals('Sync failed', updatedQA.Sync_Status__c , 'Expecting the question to be updated reflecting data is not in sync');
        system.assertEquals(true, updatedQA.Sync_Details__c.contains('The callout to ArtisanRestApiCallouts.updateQuestionAnswer failed to replicate Artisan Question with Id=['), 'Expecting the sync details to contain the Exception [' + updatedQA.Sync_Details__c + ']');
    }
}