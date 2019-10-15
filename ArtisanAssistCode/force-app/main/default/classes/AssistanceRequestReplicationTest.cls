/**
 * Artisan Assistance class to handle testing assistance request object insert/update with supporting trigger and platform event functionality
 *
 * @author Richard Clarke
 * @date 29/07/2019
 */
@isTest
public class AssistanceRequestReplicationTest {
    
    // Test the handling when a Request for Assistance is created then updated and works as it should
    static testMethod void testRequestInsertUpdate_ExpectedBehaviour() {
         // Setup callout mock response
        string mockResponseBody = '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockResponseBody, responseHeaders));

        Test.startTest();
        
        // Create a new request for assistance
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
            Stage_Name__c = 'Drafting',
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'Please help me',
            Urgency__c = 'Medium');
        insert req;

        // Update it to the next stage
		req = [
            select Id, Name, Description__c, Login_Access__c, Preferred_Billing_Currency__c, Preferred_Resource_Location__c, Preferred_Timezone__c,
            	Prior_Stage_Name__c, Date_Required__c, Salesforce_Product__c, Sandbox_Name__c, Stage_Name__c, Success_Criteria__c, Phase__c, 
            	Title__c, Urgency__c, Sync_Status__c 
            from Assistance_Request__c 
            where Id = :req.Id 
            limit 1 
            for update][0];
        
        req.Description__c = 'I need a lot of help!';
        req.Prior_Stage_Name__c = 'Drafting';
        req.Stage_Name__c = 'Waiting for Estimation';
        
        update req;

        Test.stopTest();

        // Read back the final outcome
		Assistance_Request__c updatedReq = [
            select Id, Name, Description__c, Login_Access__c, Preferred_Billing_Currency__c, Preferred_Resource_Location__c, Preferred_Timezone__c,
            	Prior_Stage_Name__c, Date_Required__c, Salesforce_Product__c, Sandbox_Name__c, Stage_Name__c, Success_Criteria__c, Phase__c, 
            	Title__c, Urgency__c, Sync_Status__c, Sync_Details__c
            from Assistance_Request__c 
            where Id = :req.Id 
            limit 1][0];

        // Insert trigger should have published an insert and the event subscriber/trigger should have called the API and updated the sync details
        system.assertEquals(updatedReq.Sync_Status__c , 'Sync successful', 'Expecting the request to be updated reflecting data is in sync');
        system.assertEquals(updatedReq.Sync_Details__c.left(17), 'Artisan Case Id=[', 'Expecting the request to be updated with the Case Id from the sync');
        
        // Quickly test the Apex controller for the lightning component
        system.assertEquals(Utils.GetNamespacePrefix(), AssistanceRequestController.getNameSpace(), 'Apex controller for component should return the namespace');
        Assistance_Request__c controllerReq = AssistanceRequestController.getAssistanceRequest(req.Id);
        system.assertEquals(req.Id,controllerReq.Id,'Apex controller for component should be able to retrieve the request record');
    }
    
    // Test the handling when a Request for Assistance fails when during the insert sync due to the API returning an exception
    static testMethod void testRequestInsert_ExceptionBehaviour() {
         // Setup callout mock response
        string mockResponseBody = '{\"Exception\":\"Assistance_Request_Id is required\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(404, mockResponseBody, responseHeaders));

        Test.startTest();
        
        // Create a new request for assistance
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
            Stage_Name__c = 'Drafting',
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'Please help me',
            Urgency__c = 'Medium');
        insert req;

        Test.stopTest();

        // Read back the final outcome
		Assistance_Request__c updatedReq = [
            select Id, Name, Description__c, Login_Access__c, Preferred_Billing_Currency__c, Preferred_Resource_Location__c, Preferred_Timezone__c,
            	Prior_Stage_Name__c, Date_Required__c, Salesforce_Product__c, Sandbox_Name__c, Stage_Name__c, Success_Criteria__c, Phase__c, 
            	Title__c, Urgency__c, Sync_Status__c, Sync_Details__c
            from Assistance_Request__c 
            where Id = :req.Id 
            limit 1][0];

        // Insert trigger should have published an insert and the event subscriber/trigger should have called the API and updated the sync details
        system.assertEquals(updatedReq.Sync_Status__c , 'Sync failed', 'Expecting the request to be updated reflecting data is not in sync');
        system.assertEquals(updatedReq.Sync_Details__c.contains('The callout to ArtisanRestApiCallouts.insertAssistanceRequest failed to replicate Assistance Request with Id'), true, 'Expecting the sync details to contain the exception [' + updatedReq.Sync_Details__c + ']');
    }
    
    // Test the handling when a Request for Assistance is created then updated and works as it should
    static testMethod void testRequestUpdate_ExpectedBehaviour() {
         // Setup callout mock response
        string mockResponseBody = '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockResponseBody, responseHeaders));

        // Create a new request for assistance
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
            Stage_Name__c = 'Drafting',
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'Please help me',
            Urgency__c = 'Medium');
        insert req;

        Test.startTest();

         // Setup callout mock response
        string exceptionMockResponseBody = '{\"Exception\":\"Assistance_Request_Id is required\"}';
        Map<String, String> exceptionResponseHeaders =  new Map<String, String> ();
        exceptionResponseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(404, exceptionMockResponseBody, exceptionResponseHeaders));

        // Update it to the next stage
		req = [
            select Id, Name, Description__c, Login_Access__c, Preferred_Billing_Currency__c, Preferred_Resource_Location__c, Preferred_Timezone__c,
            	Prior_Stage_Name__c, Date_Required__c, Salesforce_Product__c, Sandbox_Name__c, Stage_Name__c, Success_Criteria__c, Phase__c, 
            	Title__c, Urgency__c, Sync_Status__c 
            from Assistance_Request__c 
            where Id = :req.Id 
            limit 1 
            for update][0];
        
        req.Description__c = 'I need a lot of help!';
        req.Prior_Stage_Name__c = 'Drafting';
        
        update req;

        AssistanceRequestController.setNewStageNameApex( req.Id, req.Stage_Name__c = 'Waiting for Estimation' );

        Test.stopTest();

        // Read back the final outcome
		Assistance_Request__c updatedReq = [
            select Id, Name, Description__c, Login_Access__c, Preferred_Billing_Currency__c, Preferred_Resource_Location__c, Preferred_Timezone__c,
            	Prior_Stage_Name__c, Date_Required__c, Salesforce_Product__c, Sandbox_Name__c, Stage_Name__c, Success_Criteria__c, Phase__c, 
            	Title__c, Urgency__c, Sync_Status__c, Sync_Details__c
            from Assistance_Request__c 
            where Id = :req.Id 
            limit 1][0];

        // Insert trigger should have published an insert and the event subscriber/trigger should have called the API and updated the sync details
        system.assertEquals(updatedReq.Sync_Status__c , 'Sync failed', 'Expecting the request to be updated reflecting data is not in sync');
        system.assertEquals(updatedReq.Sync_Details__c.contains('The callout to ArtisanRestApiCallouts.updateAssistanceRequest failed to replicate Assistance Request with Id'), true, 'Expecting the sync details to contain the exception [' + updatedReq.Sync_Details__c + ']');
    }
    
    // Test the handling of the code which sets the phase from the stage name
    static testMethod void testPhaseFromStageName() {
        system.assertEquals( 'Estimation', AssistanceRequestReplication.PhaseFromStageName( 'Waiting for Clarification', 'Waiting for Approval' ));
        
        system.assertEquals( 'Draft', AssistanceRequestReplication.PhaseFromStageName( 'Drafting', null ));
        
        system.assertEquals( 'Estimation', AssistanceRequestReplication.PhaseFromStageName( 'Waiting for Estimation', null ));
        system.assertEquals( 'Estimation', AssistanceRequestReplication.PhaseFromStageName( 'Being Estimated', null ));
        system.assertEquals( 'Estimation', AssistanceRequestReplication.PhaseFromStageName( 'Waiting for Approval', null ));

        system.assertEquals( 'Development', AssistanceRequestReplication.PhaseFromStageName( 'Waiting for Development', null ));
        system.assertEquals( 'Development', AssistanceRequestReplication.PhaseFromStageName( 'Being Developed', null ));
                                                                                       
        system.assertEquals( 'Test', AssistanceRequestReplication.PhaseFromStageName( 'Waiting for Testing', null ));
        system.assertEquals( 'Test', AssistanceRequestReplication.PhaseFromStageName( 'Being Tested', null ));

        system.assertEquals( 'Deployment', AssistanceRequestReplication.PhaseFromStageName( 'Waiting for Deployment', null ));
        system.assertEquals( 'Deployment', AssistanceRequestReplication.PhaseFromStageName( 'Being Deployed', null ));

        system.assertEquals( 'Acceptance', AssistanceRequestReplication.PhaseFromStageName( 'Waiting for Acceptance', null ));

        system.assertEquals( 'Completed', AssistanceRequestReplication.PhaseFromStageName( 'Accepted as Complete', null ));

        system.assertEquals( 'Cancelled', AssistanceRequestReplication.PhaseFromStageName( 'Declined', null ));
        system.assertEquals( 'Cancelled', AssistanceRequestReplication.PhaseFromStageName( 'Rejected', null ));
    }
 }