/**
 * Artisan Assistance class to handle testing all callouts to the Artisan Production Org
 *
 * @author Richard Clarke
 * @date 15/07/2019
 */
@isTest
public class ArtisanRestApiCalloutsTest {

    // Test the handling when Install works as it should
    static testMethod void testpackageInstalled_ExpectedBehaviour() {
        // Setup callout mock response
        string mockResponseBody = '{\"Account.Id\":\"0010p00000Dv7TnAAJ\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockResponseBody, responseHeaders));
        
        Test.startTest();

        // Do call out without specifying a required parameter
        ArtisanRestApiCallouts.packageInstalled(
            'Undefined',
    
            'Melbourne',
            'Australia',
            'en_AU',
            'artisan-assistance-dev-ed',
            '00D123412341235',
            'AP15',
            'No',
            '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            'Anonymous Apex Assistance Package Install',
            '+61 3 8592 9000',
            '3000',
            'Installer Clarke',
            'VIC',
            'L10, 410 Collins St',
            'Enterprise',
            'JSON here for licenses',
    
            '0052v00000ZtzY0',
            'National Salesforce Practice Director',
            'Installer',
            'Clarke',
            'richard.clarke@pscgroup.com.au',
            '+61 3 8592 9000',
            '+61 410 804 829',
            'L11, 410 Collins St',
            'Melbourne',
            'Vic',
            '3000',
            'Australia');

        Test.stopTest();

        // No exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 2];
        System.assertEquals(0, logRecords.size(), 'There should be no exceptions if a legal account Id is returned');
    }

    // Test the handling when a required parameter is missing during Install
    static testMethod void testpackageInstalled_MissingRequiredParameter() {
        // Setup callout mock response
        string mockResponseBody = '{\"Exception\":\"Customer_Org_Id is the wrong length [00D12341234123]\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockResponseBody, responseHeaders));
        
        Test.startTest();

        // Do call out without specifying a required parameter
        ArtisanRestApiCallouts.packageInstalled(
            'Undefined',
    
            'Melbourne',
            'Australia',
            'en_AU',
            'artisan-assistance-dev-ed',
            '', //00D123412341235',
            'AP15',
            'No',
            '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            'Anonymous Apex Assistance Package Install',
            '+61 3 8592 9000',
            '3000',
            'Installer Clarke',
            'VIC',
            'L10, 410 Collins St',
            'Enterprise',
            'JSON here for licenses',
    
            '0052v00000ZtzY0',
            'National Salesforce Practice Director',
            'Installer',
            'Clarke',
            'richard.clarke@pscgroup.com.au',
            '+61 3 8592 9000',
            '+61 410 804 829',
            'L11, 410 Collins St',
            'Melbourne',
            'Vic',
            '3000',
            'Australia');

        Test.stopTest();

        // A single exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 2];
        System.assertEquals(1, logRecords.size(), 'Only one exception is expected to be logged when required paremters are missing');
        system.assert(logRecords[0].Message__c.Contains('Customer_Org_Id is the wrong length [00D12341234123]'), 'The exception message is unexpected [' + logRecords[0].Message__c + ']');
    }

    // Test the handling when a unexpected response status code is returned from Install
    static testMethod void testpackageInstalled_UnexpectedStatusCode() {
        // Setup callout mock response
        string mockResponseBody = '{\"Exception\":\"Customer_Org_Id is the wrong length [00D12341234123]\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(205, mockResponseBody, responseHeaders));
        
        Test.startTest();

        // Do call out without specifying a required parameter
        ArtisanRestApiCallouts.packageInstalled(
            'Undefined',
    
            'Melbourne',
            'Australia',
            'en_AU',
            'artisan-assistance-dev-ed',
            '', //00D123412341235',
            'AP15',
            'No',
            '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            'Anonymous Apex Assistance Package Install',
            '+61 3 8592 9000',
            '3000',
            'Installer Clarke',
            'VIC',
            'L10, 410 Collins St',
            'Enterprise',
            'JSON here for licenses',
    
            '0052v00000ZtzY0',
            'National Salesforce Practice Director',
            'Installer',
            'Clarke',
            'richard.clarke@pscgroup.com.au',
            '+61 3 8592 9000',
            '+61 410 804 829',
            'L11, 410 Collins St',
            'Melbourne',
            'Vic',
            '3000',
            'Australia');

        Test.stopTest();

        // A single exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 2];
        System.assertEquals(1, logRecords.size(), 'Only one exception is expected to be logged when an unexpected status code is returned');
        system.assert(logRecords[0].Message__c.Contains('The status code returned to ArtisanRestApiCallouts.packageInstalled was unexpected'), 'The exception message should include "The status code returned to ArtisanRestApiCallouts.packageInstalled was unexpected" but was ' + logRecords[0].Message__c);
    }

    // Test the handling when Uninstall works as it should
    static testMethod void testpackageUninstalled_ExpectedBehaviour() {
        // Setup callout mock response
        string mockResponseBody = '{\"Account.Id\":\"0010p00000Dv7TnAAJ\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockResponseBody, responseHeaders));
        
        Test.startTest();

        // Do call out without specifying a required parameter
        ArtisanRestApiCallouts.packageUninstalled(
            '00D123412341235',
    
            '0052v00000ZtzY0',
            'National Salesforce Practice Director',
            'Installer',
            'Clarke',
            'richard.clarke@pscgroup.com.au',
            '+61 3 8592 9000',
            '+61 410 804 829',
            'L11, 410 Collins St',
            'Melbourne',
            'Vic',
            '3000',
            'Australia');

        Test.stopTest();

        // No should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 2];
        System.assertEquals(0, logRecords.size(), 'There should be no exceptions if a legal account Id is returned');
    }

    // Test the handling when a unexpected response status code is returned from Uninstall
    static testMethod void testpackageUninstalled_UnexpectedStatusCode() {
        // Setup callout mock response
        string mockResponseBody = '{\"Exception\":\"Customer_Org_Id is the wrong length [00D12341234123]\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(205, mockResponseBody, responseHeaders));
        
        Test.startTest();

        // Do call out without specifying a required parameter
        ArtisanRestApiCallouts.packageUninstalled(
            '00D123412341235',
    
            '0052v00000ZtzY0',
            'National Salesforce Practice Director',
            'Installer',
            'Clarke',
            'richard.clarke@pscgroup.com.au',
            '+61 3 8592 9000',
            '+61 410 804 829',
            'L11, 410 Collins St',
            'Melbourne',
            'Vic',
            '3000',
            'Australia');

        Test.stopTest();

        // A single exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 2];
        System.assertEquals(1, logRecords.size(), 'Only one exception is expected to be logged when an unexpected status code is returned');
        system.assert(logRecords[0].Message__c.Contains('The status code returned to ArtisanRestApiCallouts.packageUninstalled was unexpected'), 'The exception message should include "The status code returned to ArtisanRestApiCallouts.packageUninstalled was unexpected" but was ' + logRecords[0].Message__c);
    }
    
    // Test Assistance Request callouts to create and update a request for assistance
    static testMethod void testCreateAndUpdateAssistanceRequest(){

        // Setup callout mock response
        string mockResponseBody = '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockResponseBody, responseHeaders));

        Test.startTest();

        // Create test request for assistance
        Id createdCaseId = ArtisanRestApiCallouts.insertAssistanceRequest(
            'a00123123123123', // "Assistance_Request_Id"
            'REQ1234', // "Assistance_Request_Name"
            'Waiting for Estimation', // "Assistance_Request_Stage_Name"
            'Drafting', // "Assistance_Request_Prior_Stage_Name"
            'Draft', // "Assistance_Request_Phase"
            'I need help', // "Assistance_Request_Title"
            'Please help me with Salesforce', // "Assistance_Request_Description"
            'So I will know what to do', // "Assistance_Request_Success_Criteria"
            'High', // "Assistance_Request_Urgency"
            '2019-07-31', // "Assistance_Request_Date_Required"
            'Sandbox', // "Assistance_Request_Environment"
            'Yes', // "Assistance_Request_Login_Access"
            'No', // "Assistance_Request_Production_Deployment"
            'BAU', // "Assistance_Request_Sandbox_Name"
            'Sales Cloud', // "Assistance_Request_Salesforce_Product"
            'No preference', // "Assistance_Request_Preferred_Resource_Location"
            'AUD - Australian Dollar', // "Assistance_Request_Preferred_Billing_Currency"
            '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)', // "Assistance_Request_Preferred_Timezone"
            
            '0052v00000ZtzZ0', // "Artisan_Request_Creator_User_Id"
            'Mr', // "Artisan_Request_Creator_User_Title"
            'Request', // "Artisan_Request_Creator_User_FirstName"
            'Creator', // "Artisan_Request_Creator_User_LastName"
            'richard.clarke@pscgroup.com.au', // "Artisan_Request_Creator_User_Email"
            '+61 3 8592 9000', // "Artisan_Request_Creator_User_Phone"
            '+61 410 804 829', // "Artisan_Request_Creator_User_Mobile"
            'L11, 410 Collins St', // "Artisan_Request_Creator_User_Street"
            'Melbourne', // "Artisan_Request_Creator_User_City"
            'Vic', // "Artisan_Request_Creator_User_State"
            '3000', // "Artisan_Request_Creator_User_Postalcode"
            'Australia' ); // "Artisan_Request_Creator_User_Country"        

        // update the same case
        Id updatedCaseId = ArtisanRestApiCallouts.updateAssistanceRequest(
            'a00123123123123', // "Assistance_Request_Id"
            'REQ1234', // "Assistance_Request_Name"
            'Waiting for Estimation', // "Assistance_Request_Stage_Name"
            'Drafting', // "Assistance_Request_Prior_Stage_Name"
            'Draft', // "Assistance_Request_Phase"
            'I need help', // "Assistance_Request_Title"
            'Please help me with Salesforce', // "Assistance_Request_Description"
            'So I can solve my problem', // "Assistance_Request_Success_Criteria"
            'High', // "Assistance_Request_Urgency"
            '2019-07-31', // "Assistance_Request_Date_Required"
            'Sandbox', // "Assistance_Request_Environment"
            'Yes', // "Assistance_Request_Login_Access"
            'No', // "Assistance_Request_Production_Deployment"
            'BAU', // "Assistance_Request_Sandbox_Name"
            'Sales Cloud', // "Assistance_Request_Salesforce_Product"
            'No preference', // "Assistance_Request_Preferred_Resource_Location"
            'AUD - Australian Dollar', // "Assistance_Request_Preferred_Billing_Currency"
            '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)'); // "Assistance_Request_Preferred_Timezone"

        Test.stopTest();
        
        // Return should be the case id
        System.assertEquals('5000p00000Dv7TnAAJ', String.valueOf(createdCaseId), 'The return value is expected to be a valid Case Id');
        System.assertEquals('5000p00000Dv7TnAAJ', String.valueOf(updatedCaseId), 'The return value is expected to be a valid Case Id');

        // No exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 2];
        System.assertEquals(0, logRecords.size(), 'There should be no exceptions if a legal case Id is returned');
    }
    
    // Test insert Assistance Request callouts - bad status
    static testMethod void testCreateAssistanceRequest_BadStatus(){
         // Setup callout mock response
        string mockResponseBody = '{\"Exception\":\"Assistance_Request_Id is required\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        
        Test.startTest();

        // Do call out to create a case in the Artisan org failing with 404 error
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(404, mockResponseBody, responseHeaders));
        Id createdCaseId_BadStatus = ArtisanRestApiCallouts.insertAssistanceRequest(
            null, // "Assistance_Request_Id"
            'REQ1234', // "Assistance_Request_Name"
            'Waiting for Estimation', // "Assistance_Request_Stage_Name"
            'Drafting', // "Assistance_Request_Prior_Stage_Name"
            'Draft', // "Assistance_Request_Draft"
            'I need help', // "Assistance_Request_Title"
            'Please help me with Salesforce', // "Assistance_Request_Description"
            'So I can solve my problem', // "Assistance_Request_Success_Criteria"
            'High', // "Assistance_Request_Urgency"
            '2019-07-31', // "Assistance_Request_Date_Required"
            'Sandbox', // "Assistance_Request_Environment"
            'Yes', // "Assistance_Request_Login_Access"
            'No', // "Assistance_Request_Production_Deployment"
            'BAU', // "Assistance_Request_Sandbox_Name"
            'Sales Cloud', // "Assistance_Request_Salesforce_Product"
            'No preference', // "Assistance_Request_Preferred_Resource_Location"
            'AUD - Australian Dollar', // "Assistance_Request_Preferred_Billing_Currency"
            '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)', // "Assistance_Request_Preferred_Timezone"
            
            '0052v00000ZtzZ0', // "Artisan_Request_Creator_User_Id"
            'Mr', // "Artisan_Request_Creator_User_Title"
            'Request', // "Artisan_Request_Creator_User_FirstName"
            'Creator', // "Artisan_Request_Creator_User_LastName"
            'richard.clarke@pscgroup.com.au', // "Artisan_Request_Creator_User_Email"
            '+61 3 8592 9000', // "Artisan_Request_Creator_User_Phone"
            '+61 410 804 829', // "Artisan_Request_Creator_User_Mobile"
            'L11, 410 Collins St', // "Artisan_Request_Creator_User_Street"
            'Melbourne', // "Artisan_Request_Creator_User_City"
            'Vic', // "Artisan_Request_Creator_User_State"
            '3000', // "Artisan_Request_Creator_User_Postalcode"
            'Australia' ); // "Artisan_Request_Creator_User_Country"

        Test.stopTest();
        
        // Return should be null in both cases
        System.assertEquals(null, createdCaseId_BadStatus, 'The return value is expected to be null');

        // The exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 10];
        System.assertEquals(1, logRecords.size(), 'There should be an exception');
    }
    
    // Test insert Assistance Request callouts - exception missing id
    static testMethod void testCreateAssistanceRequest_NoRequestId(){
         // Setup callout mock response
        string mockResponseBody = '{\"Exception\":\"Assistance_Request_Id is required\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        
        Test.startTest();

        // Test response when exception thrown
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockResponseBody, responseHeaders));
        Id createdCaseId_NoRequestId = ArtisanRestApiCallouts.insertAssistanceRequest(
            null, // "Assistance_Request_Id"
            'REQ1234', // "Assistance_Request_Name"
            'Waiting for Estimation', // "Assistance_Request_Stage_Name"
            'Drafting', // "Assistance_Request_Prior_Stage_Name"
            'Draft', // "Assistance_Request_Phase"
            'I need help', // "Assistance_Request_Title"
            'Please help me with Salesforce', // "Assistance_Request_Description"
            'So I can solve my problem', // "Assistance_Request_Success_Criteria"
            'High', // "Assistance_Request_Urgency"
            '2019-07-31', // "Assistance_Request_Date_Required"
            'Sandbox', // "Assistance_Request_Environment"
            'Yes', // "Assistance_Request_Login_Access"
            'No', // "Assistance_Request_Production_Deployment"
            'BAU', // "Assistance_Request_Sandbox_Name"
            'Sales Cloud', // "Assistance_Request_Salesforce_Product"
            'No preference', // "Assistance_Request_Preferred_Resource_Location"
            'AUD - Australian Dollar', // "Assistance_Request_Preferred_Billing_Currency"
            '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)', // "Assistance_Request_Preferred_Timezone"
            
            '0052v00000ZtzZ0', // "Artisan_Request_Creator_User_Id"
            'Mr', // "Artisan_Request_Creator_User_Title"
            'Request', // "Artisan_Request_Creator_User_FirstName"
            'Creator', // "Artisan_Request_Creator_User_LastName"
            'richard.clarke@pscgroup.com.au', // "Artisan_Request_Creator_User_Email"
            '+61 3 8592 9000', // "Artisan_Request_Creator_User_Phone"
            '+61 410 804 829', // "Artisan_Request_Creator_User_Mobile"
            'L11, 410 Collins St', // "Artisan_Request_Creator_User_Street"
            'Melbourne', // "Artisan_Request_Creator_User_City"
            'Vic', // "Artisan_Request_Creator_User_State"
            '3000', // "Artisan_Request_Creator_User_Postalcode"
            'Australia' ); // "Artisan_Request_Creator_User_Country"

        Test.stopTest();
        
        // Return should be null in both cases
        System.assertEquals(null, createdCaseId_NoRequestId, 'The return value is expected to be null');

        // An exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 10];
        System.assertEquals(1, logRecords.size(), 'There should be an exception');
    }
    
    // Test update Assistance Request callouts - bad status
    static testMethod void testUpdateAssistanceRequest_BadStatus(){
         // Setup callout mock response
        string mockResponseBody = '{\"Exception\":\"Assistance_Request_Id is required\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        
        Test.startTest();

        // Do call out to create a case in the Artisan org failing with 404 error
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(404, mockResponseBody, responseHeaders));
        Id createdCaseId_BadStatus = ArtisanRestApiCallouts.updateAssistanceRequest(
            null, // "Assistance_Request_Id"
            'REQ1234', // "Assistance_Request_Name"
            'Waiting for Estimation', // "Assistance_Request_Stage_Name"
            'Drafting', // "Assistance_Request_Prior_Stage_Name"
            'Draft', // "Assistance_Request_Phase"
            'I need help', // "Assistance_Request_Title"
            'Please help me with Salesforce', // "Assistance_Request_Description"
            'So I can solve my problem', // "Assistance_Request_Success_Criteria"
            'High', // "Assistance_Request_Urgency"
            '2019-07-31', // "Assistance_Request_Date_Required"
            'Sandbox', // "Assistance_Request_Environment"
            'Yes', // "Assistance_Request_Login_Access"
            'No', // "Assistance_Request_Production_Deployment"
            'BAU', // "Assistance_Request_Sandbox_Name"
            'Sales Cloud', // "Assistance_Request_Salesforce_Product"
            'No preference', // "Assistance_Request_Preferred_Resource_Location"
            'AUD - Australian Dollar', // "Assistance_Request_Preferred_Billing_Currency"
            '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)'); // "Assistance_Request_Preferred_Timezone"

        Test.stopTest();
        
        // Return should be null in both cases
        System.assertEquals(null, createdCaseId_BadStatus, 'The return value is expected to be null');

        // The exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 10];
        System.assertEquals(1, logRecords.size(), 'There should be an exception');
    }
    
    // Test Assistance Request callouts - exception missing id
    static testMethod void testUpdateAssistanceRequest_NoRequestId(){
         // Setup callout mock response
        string mockResponseBody = '{\"Exception\":\"Assistance_Request_Id is required\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        
        Test.startTest();

        // Test response when exception thrown
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockResponseBody, responseHeaders));
        Id createdCaseId_NoRequestId = ArtisanRestApiCallouts.updateAssistanceRequest(
            null, // "Assistance_Request_Id"
            'REQ1234', // "Assistance_Request_Name"
            'Waiting for Estimation', // "Assistance_Request_Stage_Name"
            'Drafting', // "Assistance_Request_Prior_Stage_Name"
            'Draft', // "Assistance_Request_Phase"
            'I need help', // "Assistance_Request_Title"
            'Please help me with Salesforce', // "Assistance_Request_Description"
            'So I can solve my problem', // "Assistance_Request_Success_Criteria"
            'High', // "Assistance_Request_Urgency"
            '2019-07-31', // "Assistance_Request_Date_Required"
            'Sandbox', // "Assistance_Request_Environment"
            'Yes', // "Assistance_Request_Login_Access"
            'No', // "Assistance_Request_Production_Deployment"
            'BAU', // "Assistance_Request_Sandbox_Name"
            'Sales Cloud', // "Assistance_Request_Salesforce_Product"
            'No preference', // "Assistance_Request_Preferred_Resource_Location"
            'AUD - Australian Dollar', // "Assistance_Request_Preferred_Billing_Currency"
            '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)'); // "Assistance_Request_Preferred_Timezone"

        Test.stopTest();
        
        // Return should be null in both cases
        System.assertEquals(null, createdCaseId_NoRequestId, 'The return value is expected to be null');

        // An exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 10];
        System.assertEquals(1, logRecords.size(), 'There should be an exception');
    }
    
    // Test Question Answer callouts to create and update a question and answer
    static testMethod void testCreateAndUpdateQuestionAnswer(){
         // Setup callout mock response
        string mockResponseBody = '{\"Question_Answer__c.Id\":\"a20123123123123\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockResponseBody, responseHeaders));
        
        Test.startTest();

        // Do call out to create a case in the Artisan org
        String createdQAId = ArtisanRestApiCallouts.insertQuestionAnswer(
            'a00123123123123', // "Assistance_Request_Id"
            'a02123123123123', // "Question_Answer_Id"
            'CQA00000001', // "Question_Answer_Ref"
            'Why will it take 5 days to migrate this data?', // "Question"
            'Customer Questioner', // "Asked_by_Name"
            'customer.questioner@gmail.com', // "Asked_by_Email"
            '+61 410 123 123' ); // "Asked_by_Phone"

        // update the same case
        String updatedQAId = ArtisanRestApiCallouts.updateQuestionAnswer(
            'a2O0p000000CFStEAO', // "Artisan_Question_Answer_Id"
            'a02123123123123', // "Question_Answer_Id"
            'AQA00000001', // "Question_Answer_Ref"
            'Customer_Question', // "Question_Answer_RecordType_Name"
            'When can I expect an estimate?', // "Question"
            'Soon!', // "Answer"
            'Customer Answerer', // "Answered_by_Name"
            'customer.answerer@gmail.com', // "Answered_by_Phone"
            '+61 410 123 126' ); // "Question"

        Test.stopTest();
        
        // Return should be the case id
        System.assertEquals('a20123123123123', String.valueOf(createdQAId), 'The return value is expected to be a valid Question & Answer Id');
        System.assertEquals('a20123123123123', String.valueOf(updatedQAId), 'The return value is expected to be a valid Question & Answer Id');

        // No exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 2];
        System.assertEquals(0, logRecords.size(), 'There should be no exceptions if a legal case Id is returned');
    }
    
    // Test insert Question Answer callouts - bad status
    static testMethod void testCreateQuestionAnswer_BadStatus(){
         // Setup callout mock response
        string mockResponseBody = '{\"Exception\":\"Assistance_Request_Id is required\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        
        Test.startTest();

        // Do call out to create a case in the Artisan org failing with 404 error
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(404, mockResponseBody, responseHeaders));
        String createdQAId_BadStatus = ArtisanRestApiCallouts.insertQuestionAnswer(
            'a00123123123123', // "Assistance_Request_Id"
            'a02123123123123', // "Question_Answer_Id"
            'CQA00000001', // "Question_Answer_Ref"
            'Why will it take 5 days to migrate this data?', // "Question"
            'Customer Questioner', // "Asked_by_Name"
            'customer.questioner@gmail.com', // "Asked_by_Email"
            '+61 410 123 123' ); // "Asked_by_Phone"

        Test.stopTest();
        
        // Return should be null in both cases
        System.assertEquals(null, createdQAId_BadStatus, 'The return value is expected to be null');

        // The exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 10];
        System.assertEquals(1, logRecords.size(), 'There should be an exception');
    }
    
    // Test insert Question Answer callouts - exception missing id
    static testMethod void testCreateQuestionAnswer_NoRequestId(){
         // Setup callout mock response
        string mockResponseBody = '{\"Exception\":\"Assistance_Request_Id is required\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        
        Test.startTest();

        // Test response when exception thrown
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockResponseBody, responseHeaders));
        String createdQAId_NoRequestId = ArtisanRestApiCallouts.insertQuestionAnswer(
            null, // "Assistance_Request_Id"
            'a02123123123123', // "Question_Answer_Id"
            'CQA00000001', // "Question_Answer_Ref"
            'Why will it take 5 days to migrate this data?', // "Question"
            'Customer Questioner', // "Asked_by_Name"
            'customer.questioner@gmail.com', // "Asked_by_Email"
            '+61 410 123 123' ); // "Asked_by_Phone"

        Test.stopTest();
        
        // Return should be null in both cases
        System.assertEquals(null, createdQAId_NoRequestId, 'The return value is expected to be null');

        // An exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 10];
        System.assertEquals(1, logRecords.size(), 'There should be an exception');
    }
    
    // Test update Question Answer callouts - bad status
    static testMethod void testUpdateQuestionAnswer_BadStatus(){
         // Setup callout mock response
        string mockResponseBody = '{\"Exception\":\"Assistance_Request_Id\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        
        Test.startTest();

        // Do call out to create a case in the Artisan org failing with 404 error
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(404, mockResponseBody, responseHeaders));
        String updatedQAId_BadStatus = ArtisanRestApiCallouts.updateQuestionAnswer(
            'a2O0p000000CFStEAO', // "Artisan_Question_Answer_Id"
            'a02123123123123', // "Question_Answer_Id"
            'AQA00000001', // "Question_Answer_Ref"
            'Customer_Question', // "Question_Answer_RecordType_Name"
            'When can I expect an estimate?', // "Question"
            'Soon!', // "Answer"
            'Customer Answerer', // "Answered_by_Name"
            'customer.answerer@gmail.com', // "Answered_by_Phone"
            '+61 410 123 126' ); // "Question"

        Test.stopTest();
        
        // Return should be null in both cases
        System.assertEquals(null, updatedQAId_BadStatus, 'The return value is expected to be null');

        // The exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 10];
        System.assertEquals(1, logRecords.size(), 'There should be an exception');
    }
    
    // Test Question Answer callouts - exception missing id
    static testMethod void testUpdateQuestionAnswer_NoRequestId(){
         // Setup callout mock response
        string mockResponseBody = '{\"Exception\":\"Question_Answer_Id is required\"}';
        Map<String, String> responseHeaders =  new Map<String, String> ();
        responseHeaders.put('Content-Type', 'application/json');
        
        Test.startTest();

        // Test response when exception thrown
        Test.setMock(HttpCalloutMock.class, new ArtisanRestApiCalloutsMock(200, mockResponseBody, responseHeaders));
        String updatedQAId_NoRequestId = ArtisanRestApiCallouts.updateQuestionAnswer(
            'a2O0p000000CFStEAO', // "Artisan_Question_Answer_Id"
            null, // "Question_Answer_Id"
            'AQA00000001', // "Question_Answer_Ref"
            'Customer_Question', // "Question_Answer_RecordType_Name"
            'When can I expect an estimate?', // "Question"
            'Soon!', // "Answer"
            'Customer Answerer', // "Answered_by_Name"
            'customer.answerer@gmail.com', // "Answered_by_Phone"
            '+61 410 123 126' ); // "Question"

        Test.stopTest();
        
        // Return should be null in both cases
        System.assertEquals(null, updatedQAId_NoRequestId, 'The return value is expected to be null');

        // An exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c limit 10];
        System.assertEquals(1, logRecords.size(), 'There should be an exception');
    }

    // Test Question Answer callouts to poll for updates - no updates available
    static testMethod void testPolling_EmptyResponse(){

        // Setup to support multiple mock responses from different end points        
        ArtisanRestApiCalloutsMock calloutMocks =  new ArtisanRestApiCalloutsMock();
        Map<String, String> responseHeaders =  new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');

        // Add mock response expected when inserting a case into the Artisan org after inserting an Assistance Request in the customer org
        calloutMocks.AddMockResponse( 'POST', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when updating a case into the Artisan org after updating an Assistance Request in the customer org
        calloutMocks.AddMockResponse( 'PUT', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response to insert Q&A
        calloutMocks.AddMockResponse( 'POST', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/', 
                                     200, '{\"Question_Answer__c.Id\":\"a020p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected from polling call when no updates are available
        calloutMocks.AddMockResponse( 'GET', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '\"{}\"', responseHeaders );

        // Set mock response
        Test.setMock(HttpCalloutMock.class, calloutMocks);
        
        // Create a request for assistance
        Datetime dtNow = Datetime.now();
        
        Assistance_Request__c req = new Assistance_Request__c(
            Description__c = 'Please help me with Salesforce',
            Login_Access__c = 'Yes',
            Preferred_Billing_Currency__c = 'AUD - Australian Dollar',
            Preferred_Resource_Location__c = 'No preference',
            Preferred_Timezone__c = '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            Prior_Stage_Name__c = 'Drafting',
            Date_Required__c = Date.valueOf('2019-07-31'),
            Salesforce_Product__c = 'Sales Cloud',
            Environment__c = 'Sandbox',
            Sandbox_Name__c = 'BAU',
            Production_Deployment__c = 'No',
            Stage_Name__c = 'Waiting for Estimation',
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'I need help',
            Urgency__c = 'High',
        	Artisan_Case_SystemModstamp__c = dtNow);
        database.insert(req);

        // Insert the customer question
        Question_Answer__c qa = new Question_Answer__c(
            RecordTypeId = Utils.GetCustomerQuestionAnswerRecordTypeId(),
            Assistance_Request_Id__c = req.Id,
            Question__c = 'Why is the estimate so high?');
        database.insert(qa);

        // Start the test here so the callout to get updates is in a different context to the DML above
        Test.startTest();

        // Poll for changes using the scheduled batch class which calls a queuable class which calls the API
        SchedulableContext sc = null;
        AssistanceRequestSchedulableBatch sb = new AssistanceRequestSchedulableBatch();
        sb.Execute(sc);
        
        Test.stopTest();

        // There should be 1 assistance request with no Artisan case systemmodstamp and 0 questions
        List<Assistance_Request__c> reqs = [Select Id, Name, Artisan_Case_SystemModstamp__c from Assistance_Request__c readonly limit 10];
        System.assertEquals(1, reqs.size(), 'There should be 1 assistance request');
        System.assertEquals(dtNow, reqs[0].Artisan_Case_SystemModstamp__c, 'There should be no change in the systemmodstamp recorded' );
        
        List<Question_Answer__c> qas = [select Id, Name, Artisan_Question_Answer_Id__c from Question_Answer__c readonly limit 10];
        System.assertEquals(1, qas.size(), 'There should be 1 question');

        // No exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c];
        System.assertEquals(0, logRecords.size(), 'There should be no exceptions: ' + logRecords);
    }

    // Test Question Answer callouts to poll for updates - update to request available only (no questions)
    static testMethod void testPolling_RequestWithNoQuestions(){

        // Setup to support multiple mock responses from different end points        
        ArtisanRestApiCalloutsMock calloutMocks =  new ArtisanRestApiCalloutsMock();
        Map<String, String> responseHeaders =  new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');

        // Add mock response expected when inserting a case into the Artisan org after inserting an Assistance Request in the customer org
        calloutMocks.AddMockResponse( 'POST', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when inserting a case into the Artisan org after inserting an Assistance Request in the customer org
        calloutMocks.AddMockResponse( 'PUT', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}', responseHeaders );

        // Set mock response
        Test.setMock(HttpCalloutMock.class, calloutMocks);
        
        // Create a request for assistance
        Assistance_Request__c req = new Assistance_Request__c(
            Description__c = 'Please help me with Salesforce',
            Login_Access__c = 'Yes',
            Preferred_Billing_Currency__c = 'AUD - Australian Dollar',
            Preferred_Resource_Location__c = 'No preference',
            Preferred_Timezone__c = '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            Prior_Stage_Name__c = 'Drafting',
            Date_Required__c = Date.valueOf('2019-07-31'),
            Salesforce_Product__c = 'Sales Cloud',
            Environment__c = 'Sandbox',
            Sandbox_Name__c = 'BAU',
            Production_Deployment__c = 'No',
            Stage_Name__c = 'Waiting for Estimation',
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'I need help',
            Urgency__c = 'High');
        insert req;

        // Add mock response expected from polling call when only the request update is available
        calloutMocks.AddMockResponse( 'GET', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '"{\"AssistanceRequest\":{\"attributes\":{\"type\":\"Case\",\"url\":\"/services/data/v46.0/sobjects/Case/5000p000000tgujAAA\"},\"Id\":\"5000p000000tgujAAA\",\"Assistance_Request_Id__c\":\"' + req.Id + '\",\"Subject\":\"this one has no questions\",\"SystemModstamp\":\"2019-07-31T06:00:20.000+0000\",\"Status\":\"Drafting\",\"Actual_Cost__c\":300000.00,\"Actual_End_Date__c\":\"2019-11-21\",\"Actual_Person_Days__c\":120.00,\"Actual_Start_Date__c\":\"2019-08-12\",\"Estimated_Cost__c\":250000.00,\"Estimated_End_Date__c\":\"2019-10-31\",\"Estimated_Person_Days__c\":100.00,\"Estimated_Start_Date__c\":\"2019-09-02\"}}"', responseHeaders );

        // Set mock response
        Test.setMock(HttpCalloutMock.class, calloutMocks);
        
        // Start the test here so the callout to get updates is in a different context to the DML above
        Test.startTest();

        // Do call out to poll for updates using the refresh now controller
        AssistanceRequestController.pollArtisanNowApex( req.Id );

        Test.stopTest();

        // There should be 1 assistance request with an Artisan case systemmodstamp and 0 questions
        List<Assistance_Request__c> reqs = [Select Id, Name, Artisan_Case_SystemModstamp__c from Assistance_Request__c readonly limit 10];
        System.assertEquals(1, reqs.size(), 'There should be 1 assistance request');
        System.assertNotEquals(null, reqs[0].Artisan_Case_SystemModstamp__c, 'There should be a defined case systemmodstamp from the update' );
        
        List<Question_Answer__c> qas = [select Id, Name, Artisan_Question_Answer_Id__c from Question_Answer__c readonly limit 10];
        System.assertEquals(0, qas.size(), 'There should be 0 questions');

        // No exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c];
        System.assertEquals(0, logRecords.size(), 'There should be no exceptions [' + logRecords + ']');
    }

    // Test Question Answer callouts to poll for updates - update to request available only (no questions)
    static testMethod void testPolling_RequestWithNewArtisanQuestion(){

        // Setup to support multiple mock responses from different end points        
        ArtisanRestApiCalloutsMock calloutMocks =  new ArtisanRestApiCalloutsMock();
        Map<String, String> responseHeaders =  new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');

        // Add mock response expected when inserting a case into the Artisan org after inserting an Assistance Request in the customer org
        calloutMocks.AddMockResponse( 'POST', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when inserting a case into the Artisan org after inserting an Assistance Request in the customer org
        calloutMocks.AddMockResponse( 'PUT', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when adding a question
        calloutMocks.AddMockResponse( 'POST', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/', 
                                     200, '{\"Question_Answer__c.Id\":\"a020p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when updating a customer question
        calloutMocks.AddMockResponse( 'PUT', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/', 
                                     200, '{\"Question_Answer__c.Id\":\"a020p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when updating an artisan question
        calloutMocks.AddMockResponse( 'PATCH', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/', 
                                     200, '{\"Question_Answer__c.Id\":\"a020p00000Dv7TnAAJ\"}', responseHeaders );

        // Set mock response
        Test.setMock(HttpCalloutMock.class, calloutMocks);
        
        // Create a request for assistance
        Assistance_Request__c req = new Assistance_Request__c(
            Description__c = 'Please help me with Salesforce',
            Login_Access__c = 'Yes',
            Preferred_Billing_Currency__c = 'AUD - Australian Dollar',
            Preferred_Resource_Location__c = 'No preference',
            Preferred_Timezone__c = '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            Prior_Stage_Name__c = 'Drafting',
            Date_Required__c = Date.valueOf('2019-07-31'),
            Salesforce_Product__c = 'Sales Cloud',
            Environment__c = 'Sandbox',
            Sandbox_Name__c = 'BAU',
            Production_Deployment__c = 'No',
            Stage_Name__c = 'Waiting for Estimation',
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'I need help',
            Urgency__c = 'High');
        insert req;

        // Add mock response expected from polling call when a request update is available with a new Artisan question
        calloutMocks.AddMockResponse( 'GET', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '"{\"AssistanceRequest\":{\"attributes\":{\"type\":\"Case\",\"url\":\"/services/data/v46.0/sobjects/Case/5000p000000tgujAAA\"},\"Id\":\"5000p000000tgujAAA\",\"Assistance_Request_Id__c\":\"' + req.Id + '\",\"Subject\":\"this one has one Artisan question\",\"SystemModstamp\":\"2019-07-31T06:23:40.000+0000\",\"Status\":\"Drafting\",\"Actual_Cost__c\":300000.00,\"Actual_End_Date__c\":\"2019-11-21\",\"Actual_Person_Days__c\":120.00,\"Actual_Start_Date__c\":\"2019-08-12\",\"Estimated_Cost__c\":250000.00,\"Estimated_End_Date__c\":\"2019-10-31\",\"Estimated_Person_Days__c\":100.00,\"Estimated_Start_Date__c\":\"2019-09-02\",\"Questions_Answers__r\":{\"totalSize\":1,\"done\":true,\"records\":[{\"attributes\":{\"type\":\"Question_Answer__c\",\"url\":\"/services/data/v46.0/sobjects/Question_Answer__c/a2O0p000000CHjfEAG\"},\"Case_Id__c\":\"5000p000000tgujAAA\",\"Id\":\"a2O0p000000CHjfEAG\",\"Name\":\"AQA00000140\",\"SystemModstamp\":\"2019-07-31T06:23:40.000+0000\",\"RecordTypeId\":\"0120p0000005iYYAAY\",\"Question__c\":\"<p>A question from Artisan</p>\",\"Asked_by_Name__c\":\"Richard Clarke\",\"Asked_by_Email__c\":\"richard.clarke@pscgroup.com.au\",\"Asked_by_Phone__c\":\"+61 61410804829\",\"RecordType\":{\"attributes\":{\"type\":\"RecordType\",\"url\":\"/services/data/v46.0/sobjects/RecordType/0120p0000005iYYAAY\"},\"Id\":\"0120p0000005iYYAAY\",\"DeveloperName\":\"Artisan_Question\"}}]}}}"', responseHeaders );

        // Set mock response
        Test.setMock(HttpCalloutMock.class, calloutMocks);
        
        // Start the test here so the callout to get updates is in a different context to the DML above
        Test.startTest();

        // Do call out to poll for updates - this will collect and create the new Artisan question
        String requestId = ArtisanRestApiCallouts.getRequestUpdates(
            req.Id, // "Assistance_Request_Id"
            ''); // "Artisan_Case_SystemModstamp"
  
        // Return should be the Artisan org case id or null if no data was returned
        System.assertEquals(req.Id, requestId, 'The return value should be the request id if the data returned contains an update');
        
        Test.stopTest();

        // There should be 1 assistance request with an Artisan case systemmodstamp and 0 questions
        List<Assistance_Request__c> reqs = [Select Id, Name, Artisan_Case_SystemModstamp__c from Assistance_Request__c readonly limit 10];
        System.assertEquals(1, reqs.size(), 'There should be 1 assistance request');
        System.assertNotEquals(null, reqs[0].Artisan_Case_SystemModstamp__c, 'There should be a defined case systemmodstamp from the update' );
        
        List<Question_Answer__c> qas = [select Id, Name, Artisan_Question_Answer_Id__c, RecordTypeId, Assistance_Request_Id__c from Question_Answer__c readonly limit 10];
        System.assertEquals(1, qas.size(), 'There should be 1 question');
        system.assertEquals(Utils.GetArtisanQuestionAnswerRecordTypeId(), qas[0].RecordTypeId, 'Expecting an Artisan question record type');
        system.assertNotEquals(null, qas[0].Artisan_Question_Answer_Id__c, 'Expecting the Artisan question answer id to be set');
        system.assertEquals(req.Id, qas[0].Assistance_Request_Id__c, 'Expecting the new question to be linked to the request');

        // No exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c];
        System.assertEquals(0, logRecords.size(), 'There should be no exceptions [' + logRecords + ']');
    }

    // Test Question Answer callouts to poll for updates - update to request available only (no questions)
    static testMethod void testPolling_RequestWithUpdatedArtisanQuestion(){

        // Setup to support multiple mock responses from different end points        
        ArtisanRestApiCalloutsMock calloutMocks =  new ArtisanRestApiCalloutsMock();
        Map<String, String> responseHeaders =  new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');

        // Add mock response expected when inserting a case into the Artisan org after inserting an Assistance Request in the customer org
        calloutMocks.AddMockResponse( 'POST', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when updating an Assistance Request in the customer org
        calloutMocks.AddMockResponse( 'PUT', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when adding a question
        calloutMocks.AddMockResponse( 'POST', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/', 
                                     200, '{\"Question_Answer__c.Id\":\"a020p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when updating a customer question
        calloutMocks.AddMockResponse( 'PUT', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/', 
                                     200, '{\"Question_Answer__c.Id\":\"a020p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when updating an artisan question
        calloutMocks.AddMockResponse( 'PATCH', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/', 
                                     200, '{\"Question_Answer__c.Id\":\"a020p00000Dv7TnAAJ\"}', responseHeaders );

        // Set mock response
        Test.setMock(HttpCalloutMock.class, calloutMocks);
        
        // Create a request for assistance
        Assistance_Request__c req = new Assistance_Request__c(
            Description__c = 'this one has one artisan question',
            Login_Access__c = 'Yes',
            Preferred_Billing_Currency__c = 'AUD - Australian Dollar',
            Preferred_Resource_Location__c = 'No preference',
            Preferred_Timezone__c = '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            Prior_Stage_Name__c = 'Waiting for Estimation',
            Date_Required__c = Date.valueOf('2019-07-31'),
            Salesforce_Product__c = 'Sales Cloud',
            Environment__c = 'Sandbox',
            Sandbox_Name__c = 'BAU',
            Production_Deployment__c = 'No',
            Stage_Name__c = 'Waiting for Estimation',
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'I need help',
            Urgency__c = 'High');
        insert req;

        // Create an Artisan question manually to setup the starting test setup to reflect a request with an artisan asked question
        Question_Answer__c qa = new Question_Answer__c(
            RecordTypeId = Utils.GetArtisanQuestionAnswerRecordTypeId(),
            Artisan_Question_Answer_Id__c = 'a020p00000Dv7TnAAJ',
            Assistance_Request_Id__c = req.Id,
            Question__c = 'How will you decide when this work is complete?');
        insert qa;

        // Add mock response expected from polling call when a request update is available with an updated Artisan question
        calloutMocks.AddMockResponse( 'GET', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '"{\"AssistanceRequest\":{\"attributes\":{\"type\":\"Case\",\"url\":\"/services/data/v46.0/sobjects/Case/5000p000000tgujAAA\"},\"Id\":\"5000p000000tgujAAA\",\"Assistance_Request_Id__c\":\"' + req.Id + '\",\"Subject\":\"this one has one artisan question\",\"SystemModstamp\":\"2019-08-01T03:40:34.000+0000\",\"Status\":\"Waiting for Acceptance\",\"Prior_Stage_Name__c\":\"Being Deployed\",\"Actual_Cost__c\":300000.00,\"Actual_End_Date__c\":\"2019-11-21\",\"Actual_Person_Days__c\":120.00,\"Actual_Start_Date__c\":\"2019-08-12\",\"Estimated_Cost__c\":250000.00,\"Estimated_End_Date__c\":\"2019-10-31\",\"Estimated_Person_Days__c\":100.00,\"Estimated_Start_Date__c\":\"2019-09-02\",\"Questions_Answers__r\":{\"totalSize\":1,\"done\":true,\"records\":[{\"attributes\":{\"type\":\"Question_Answer__c\",\"url\":\"/services/data/v46.0/sobjects/Question_Answer__c/a2O0p000000CHjfEAG\"},\"Case_Id__c\":\"5000p000000tgujAAA\",\"Id\":\"' + qa.Artisan_Question_Answer_Id__c + '\",\"Name\":\"AQA00000140\",\"SystemModstamp\":\"2019-07-31T06:23:40.000+0000\",\"RecordTypeId\":\"0120p0000005iYYAAY\",\"Question__c\":\"<p>A question from Artisan</p>\",\"Answer__c\":\"<p>An answer from the customer</p>\",\"Asked_by_Name__c\":\"Richard Clarke\",\"Asked_by_Email__c\":\"richard.clarke@pscgroup.com.au\",\"Asked_by_Phone__c\":\"+61 61410804829\",\"Answered_by_Name__c\":\"Richard Clarke\",\"Answered_by_Email__c\":\"richard.clarke@pscgroup.com.au\",\"Answered_by_Phone__c\":\"+61 61410804829\",\"RecordType\":{\"attributes\":{\"type\":\"RecordType\",\"url\":\"/services/data/v46.0/sobjects/RecordType/0120p0000005iYYAAY\"},\"Id\":\"0120p0000005iYYAAY\",\"Customer_Question_Answer_Id__c\":\"' + qa.Id + '\",\"DeveloperName\":\"Artisan_Question\"}}]}}}"',  responseHeaders );

        // Set mock response
        Test.setMock(HttpCalloutMock.class, calloutMocks);

        // Start the test here so the callout to get updates is in a different context to the DML above
        Test.startTest();

        // Do call out to poll for updates - this will collect and create the new Artisan question
        String requestId = ArtisanRestApiCallouts.getRequestUpdates(
            req.Id, // "Assistance_Request_Id"
            ''); // "Artisan_Case_SystemModstamp"
  
        // Return should be the Artisan org case id or null if no data was returned
        System.assertEquals(req.Id, requestId, 'The return value should be the request id if the data returned contains an update');
        
        Test.stopTest();

        // There should be 1 assistance request with an Artisan case systemmodstamp and 0 questions
        List<Assistance_Request__c> reqs = [Select Id, Name, Artisan_Case_SystemModstamp__c from Assistance_Request__c readonly limit 10];
        System.assertEquals(1, reqs.size(), 'There should be 1 assistance request');
        System.assertNotEquals(null, reqs[0].Artisan_Case_SystemModstamp__c, 'There should be a defined case systemmodstamp from the update' );
        
        List<Question_Answer__c> qas = [select Id, Name, Artisan_Question_Answer_Id__c, RecordTypeId, Assistance_Request_Id__c from Question_Answer__c readonly limit 10];
        System.assertEquals(1, qas.size(), 'There should be 1 question');
        system.assertEquals(Utils.GetArtisanQuestionAnswerRecordTypeId(), qas[0].RecordTypeId, 'Expecting an Artisan question record type');
        system.assertNotEquals(null, qas[0].Artisan_Question_Answer_Id__c, 'Expecting the Artisan question answer id to be set');
        system.assertEquals(req.Id, qas[0].Assistance_Request_Id__c, 'Expecting the new question to be linked to the request');

        // No exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c];
        System.assertEquals(0, logRecords.size(), 'There should be no exceptions');
    }
    
    // Polling example with a request at the final waiting for acceptance stage prior to billing, 1 artisan question, 1 customer question, all fields filled in
    // Pre-create a request and a customer question without an answer, then polling and receive back a fully completed request and two questions
    // Test Question Answer callouts to poll for updates - update to request available only (no questions)
    static testMethod void testPolling_RequestWaitingForAcceptance(){

        // Setup to support multiple mock responses from different end points        
        ArtisanRestApiCalloutsMock calloutMocks =  new ArtisanRestApiCalloutsMock();
        Map<String, String> responseHeaders =  new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');

        // Add mock response expected when inserting a case into the Artisan org after inserting an Assistance Request in the customer org
        calloutMocks.AddMockResponse( 'POST', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when updating an Assistance Request in the customer org
        calloutMocks.AddMockResponse( 'PUT', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when adding a question
        calloutMocks.AddMockResponse( 'POST', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/', 
                                     200, '{\"Question_Answer__c.Id\":\"a020p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when updating a customer question
        calloutMocks.AddMockResponse( 'PUT', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/', 
                                     200, '{\"Question_Answer__c.Id\":\"a020p00000Dv7TnAAJ\"}', responseHeaders );

        // Add mock response expected when updating an artisan question
        calloutMocks.AddMockResponse( 'PATCH', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/', 
                                     200, '{\"Question_Answer__c.Id\":\"a020p00000Dv7TnAAJ\"}', responseHeaders );

        // Set mock response
        Test.setMock(HttpCalloutMock.class, calloutMocks);
        
        // Create a request for assistance
        Assistance_Request__c req = new Assistance_Request__c(
            Description__c = 'medium urgency for sales cloud required by 31 Aug 2019 with resources in my country',
            Login_Access__c = 'Yes',
            Preferred_Billing_Currency__c = 'AUD - Australian Dollar',
            Preferred_Resource_Location__c = 'No preference',
            Preferred_Timezone__c = '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            Prior_Stage_Name__c = 'Drafting',
            Date_Required__c = Date.valueOf('2019-07-31'),
            Salesforce_Product__c = 'Sales Cloud',
            Environment__c = 'Sandbox',
            Sandbox_Name__c = 'BAU',
            Production_Deployment__c = 'Yes',
            Stage_Name__c = 'Waiting for Estimation',
            Success_Criteria__c = 'The work gets done!',
            Title__c = 'This request will have 1 artisan question and 1 customer question',
            Urgency__c = 'Medium');
        insert req;

        // Create an Artisan question manually to setup the starting test setup to reflect a request with a customer asked question
        Question_Answer__c qa = new Question_Answer__c(
            RecordTypeId = Utils.GetCustomerQuestionAnswerRecordTypeId(),
            Assistance_Request_Id__c = req.Id,
            Asked_by_Name__c = 'Ashwin Kumar Kondapally',
            Asked_by_Email__c = 'ashwin.kondapally@pscgroup.com.au',
            Asked_by_Phone__c = '+61 410 123 123',
            Question__c = 'When will you be able to provide the estimate?');
        insert qa;

        // There should be 1 assistance request with an Artisan case systemmodstamp and 0 questions
        List<Assistance_Request__c> reqs = [
            Select Id, Stage_Name__c, Title__c, Artisan_Case_SystemModstamp__c, Prior_Stage_Name__c, Phase__c, 
                Estimated_Cost__c, Estimated_End_Date__c, Estimated_Person_Days__c, Estimated_Start_Date__c, Estimated_Cost_Commentary__c,
                Actual_Cost__c, Actual_End_Date__c, Actual_Person_Days__c, Actual_Start_Date__c, Actual_Cost_Commentary__c, Open_Question_Count__c
            from Assistance_Request__c readonly 
            limit 10];
        System.assertEquals( 1, reqs.size(), 'There should be 1 assistance request' );
        System.assertEquals( 1, reqs[0].Open_Question_Count__c, 'There should one open question' );
        System.assertEquals( 'Estimation', reqs[0].Phase__c, 'The phase should be Estimation' );
        System.assertEquals( 'Waiting for Clarification', reqs[0].Stage_Name__c, 'The stage should be Waiting for Clarification with one open question' );
        System.assertEquals( 'Waiting for Estimation', reqs[0].Prior_Stage_Name__c, 'The prior stage should be Waiting for Estimation' );

        // Add mock response expected from polling call when a request update is available with an updated Artisan question
        calloutMocks.AddMockResponse( 'GET', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '"{\"AssistanceRequest\":{\"attributes\":{\"type\":\"Case\",\"url\":\"/services/data/v46.0/sobjects/Case/5000p000000tgujAAA\"},\"Id\":\"5000p000000tgujAAA\",\"Assistance_Request_Id__c\":\"' + req.Id + '\",\"Subject\":\"This request has 1 artisan question and 1 customer question\",\"SystemModstamp\":\"2019-08-01T05:06:11.000+0000\",\"Status\":\"Waiting for Acceptance\",\"Prior_Stage_Name__c\":\"Waiting for Estimation\",\"Actual_Cost__c\":300000.00,\"Actual_End_Date__c\":\"2019-11-21\",\"Actual_Person_Days__c\":120.00,\"Actual_Start_Date__c\":\"2019-08-12\",\"Actual_Cost_Commentary__c\":\"This is why the costs are higher than estimated\",\"Estimated_Cost__c\":250000.00,\"Estimated_End_Date__c\":\"2019-10-31\",\"Estimated_Person_Days__c\":100.00,\"Estimated_Start_Date__c\":\"2019-09-02\",\"Estimated_Cost_Commentary__c\":\"This is why it will cost this much\",\"Questions_Answers__r\":{\"totalSize\":2,\"done\":true,\"records\":[{\"attributes\":{\"type\":\"Question_Answer__c\",\"url\":\"/services/data/v46.0/sobjects/Question_Answer__c/a2O0p000000CHjfEAG\"},\"Case_Id__c\":\"5000p000000tgujAAA\",\"Id\":\"a2O0p000000CHjfEAG\",\"Name\":\"AQA00000140\",\"SystemModstamp\":\"2019-08-01T05:04:01.000+0000\",\"RecordTypeId\":\"0120p0000005iYYAAY\",\"Question__c\":\"<p>When will you be able to supply us with the data you want migrated?</p>\",\"Asked_by_Name__c\":\"Richard Clarke\",\"Asked_by_Email__c\":\"richard.clarke@pscgroup.com.au\",\"Asked_by_Phone__c\":\"+61 61410804829\",\"Answer__c\":\"<p>We will have the data available in two weeks</p>\",\"Answered_by_Name__c\":\"Customer Admin\",\"Answered_by_Email__c\":\"customer.admin@gmail.com\",\"Answered_by_Phone__c\":\"+61 410 345 345\",\"RecordType\":{\"attributes\":{\"type\":\"RecordType\",\"url\":\"/services/data/v46.0/sobjects/RecordType/0120p0000005iYYAAY\"},\"Id\":\"0120p0000005iYYAAY\",\"DeveloperName\":\"Artisan_Question\"}},{\"attributes\":{\"type\":\"Question_Answer__c\",\"url\":\"/services/data/v46.0/sobjects/Question_Answer__c/a2O0p000000CHkYEAW\"},\"Case_Id__c\":\"5000p000000tgujAAA\",\"Id\":\"a2O0p000000CHkYEAW\",\"Customer_Question_Answer_Id__c\":\"' + qa.id + '\",\"Name\":\"AQA00000143\",\"SystemModstamp\":\"2019-08-01T04:27:40.000+0000\",\"RecordTypeId\":\"0120p0000005iYdAAI\",\"Question__c\":\"<p>When will you be able to provide the estimate?</p>\",\"Asked_by_Name__c\":\"Ashwin Kumar Kondapally\",\"Asked_by_Email__c\":\"ashwin.kondapally@pscgroup.com.au\",\"Asked_by_Phone__c\":\"+61 410 123 123\",\"Answer__c\":\"<p>Very soon</p>\",\"Answered_by_Name__c\":\"Richard Clarke\",\"Answered_by_Email__c\":\"richard.clarke@pscgroup.com.au\",\"Answered_by_Phone__c\":\"+61 61410804829\",\"RecordType\":{\"attributes\":{\"type\":\"RecordType\",\"url\":\"/services/data/v46.0/sobjects/RecordType/0120p0000005iYdAAI\"},\"Id\":\"0120p0000005iYdAAI\",\"DeveloperName\":\"Customer_Question\"}}]}}}"', responseHeaders );

        // Set mock response
        Test.setMock(HttpCalloutMock.class, calloutMocks);

        // Start the test here so the callout to get updates is in a different context to the DML above
        Test.startTest();

        // Do call out to poll for updates - this will collect and create the new Artisan question
        String requestId = ArtisanRestApiCallouts.getRequestUpdates(
            req.Id, // "Assistance_Request_Id"
            ''); // "Artisan_Case_SystemModstamp"
  
        // Return should be the Artisan org case id or null if no data was returned
        System.assertEquals(req.Id, requestId, 'The return value should be the request id if the data returned contains an update');
        
        Test.stopTest();

        // There should be 1 assistance request with an Artisan case systemmodstamp and 0 questions
        reqs = [
            Select Id, Stage_Name__c, Title__c, Artisan_Case_SystemModstamp__c, Prior_Stage_Name__c, Phase__c, 
                Estimated_Cost__c, Estimated_End_Date__c, Estimated_Person_Days__c, Estimated_Start_Date__c, Estimated_Cost_Commentary__c,
                Actual_Cost__c, Actual_End_Date__c, Actual_Person_Days__c, Actual_Start_Date__c, Actual_Cost_Commentary__c, Open_Question_Count__c
            from Assistance_Request__c readonly 
            limit 10];
        System.assertEquals(1, reqs.size(), 'There should be 1 assistance request');
        System.assertNotEquals(null, reqs[0].Artisan_Case_SystemModstamp__c, 'There should be a defined case systemmodstamp from the update' );
        System.assertEquals(0, reqs[0].Open_Question_Count__c, 'There should be no open questions' );
        
        List<Question_Answer__c> qas = [
            select Id, Name, 
                Artisan_Question_Answer_Id__c, RecordTypeId, Assistance_Request_Id__c, 
                Question__c, Asked_by_Name__c, Asked_by_Email__c, Asked_by_Phone__c,
                Answer__c, Answered_by_Name__c, Answered_by_Email__c, Answered_by_Phone__c, IsOpen__c
            from Question_Answer__c readonly 
            limit 10];
        System.assertEquals(2, qas.size(), 'There should be 2 questions');

        // Question 0 is the Customer question
        system.assertEquals(Utils.GetCustomerQuestionAnswerRecordTypeId(), qas[0].RecordTypeId, 'Expecting a Customer question record type');
        system.assertNotEquals(null, qas[0].Artisan_Question_Answer_Id__c, 'Expecting the Artisan question answer id to be set');
        system.assertEquals(req.Id, qas[0].Assistance_Request_Id__c, 'Expecting the new question to be linked to the request');
        system.assertEquals(false, qas[0].IsOpen__c, 'Expecting the question not to be open as an answer has been provided');

        // Question 1 is the Artisan question
        system.assertEquals(Utils.GetArtisanQuestionAnswerRecordTypeId(), qas[1].RecordTypeId, 'Expecting an Artisan question record type');
        system.assertNotEquals(null, qas[1].Artisan_Question_Answer_Id__c, 'Expecting the Artisan question answer id to be set');
        system.assertEquals(req.Id, qas[1].Assistance_Request_Id__c, 'Expecting the new question to be linked to the request');
        system.assertEquals(false, qas[1].IsOpen__c, 'Expecting the question not to be open as an answer has been provided');

        // No exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c];
        System.assertEquals(0, logRecords.size(), 'There should be no exceptions');
        
        // Verify the request data fields are populated from the JSON as expected
        system.assertEquals( 'Waiting for Acceptance', reqs[0].Stage_Name__c );
        system.assertEquals( 'Acceptance', reqs[0].Phase__c );
        system.assertEquals( 250000.0, reqs[0].Estimated_Cost__c );
        system.assertEquals( Date.valueOf('2019-10-31'), reqs[0].Estimated_End_Date__c );
        system.assertEquals( 100.0, reqs[0].Estimated_Person_Days__c );
        system.assertEquals( Date.valueOf('2019-09-02'), reqs[0].Estimated_Start_Date__c );
        system.assertEquals( 'This is why it will cost this much', reqs[0].Estimated_Cost_Commentary__c );
        system.assertEquals( 300000.0, reqs[0].Actual_Cost__c );
        system.assertEquals( Date.valueOf('2019-11-21'), reqs[0].Actual_End_Date__c );
        system.assertEquals( 120.0, reqs[0].Actual_Person_Days__c );
        system.assertEquals( Date.valueOf('2019-08-12'), reqs[0].Actual_Start_Date__c );
        system.assertEquals( 'This is why the costs are higher than estimated', reqs[0].Actual_Cost_Commentary__c );
        system.assertEquals( 'This request has 1 artisan question and 1 customer question', reqs[0].Title__c );
        system.assertEquals( DateTime.valueOfGmt('2019-08-01 05:06:11.000+0000'), reqs[0].Artisan_Case_SystemModstamp__c );

        // Verify the question 0 (Customer asked) data fields are populated from the JSON as expected
        system.assertEquals( Utils.GetCustomerQuestionAnswerRecordTypeId(), qas[0].RecordTypeId );
        system.assertEquals( 'a2O0p000000CHkYEAW', qas[0].Artisan_Question_Answer_Id__c );
        system.assertEquals( '<p>When will you be able to provide the estimate?</p>', qas[0].Question__c );
        system.assertEquals( 'Ashwin Kumar Kondapally', qas[0].Asked_by_Name__c );
        system.assertEquals( 'ashwin.kondapally@pscgroup.com.au', qas[0].Asked_by_Email__c  );
        system.assertEquals( '+61 410 123 123', qas[0].Asked_by_Phone__c );
        system.assertEquals( '<p>Very soon</p>', qas[0].Answer__c );
        system.assertEquals( 'Richard Clarke', qas[0].Answered_by_Name__c );
        system.assertEquals( 'richard.clarke@pscgroup.com.au', qas[0].Answered_by_Email__c );
        system.assertEquals( '+61 61410804829', qas[0].Answered_by_Phone__c );

        // Verify the question 1 (Artisan asked) data fields are populated from the JSON as expected
        system.assertEquals( Utils.GetArtisanQuestionAnswerRecordTypeId(), qas[1].RecordTypeId );
        system.assertEquals( 'a2O0p000000CHjfEAG', qas[1].Artisan_Question_Answer_Id__c );
        system.assertEquals( '<p>When will you be able to supply us with the data you want migrated?</p>', qas[1].Question__c );
        system.assertEquals( 'Richard Clarke', qas[1].Asked_by_Name__c );
        system.assertEquals( 'richard.clarke@pscgroup.com.au', qas[1].Asked_by_Email__c  );
        system.assertEquals( '+61 61410804829', qas[1].Asked_by_Phone__c );
        system.assertEquals( '<p>We will have the data available in two weeks</p>', qas[1].Answer__c );
        system.assertEquals( 'Customer Admin', qas[1].Answered_by_Name__c );
        system.assertEquals( 'customer.admin@gmail.com', qas[1].Answered_by_Email__c );
        system.assertEquals( '+61 410 345 345', qas[1].Answered_by_Phone__c );
    }
    
    // Negative case where polling query returns an unexpected status code
    static testMethod void testPolling_RequestBadStatus(){

        // Setup to support multiple mock responses from different end points        
        ArtisanRestApiCalloutsMock calloutMocks =  new ArtisanRestApiCalloutsMock();
        Map<String, String> responseHeaders =  new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');

        // Add mock response expected when inserting a case into the Artisan org after inserting an Assistance Request in the customer org
        calloutMocks.AddMockResponse( 'POST', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}', responseHeaders );

        // Set mock response
        Test.setMock(HttpCalloutMock.class, calloutMocks);
        
        // Create a request for assistance
        Assistance_Request__c req = new Assistance_Request__c(
            Description__c = 'Please help me with Salesforce',
            Login_Access__c = 'Yes',
            Preferred_Billing_Currency__c = 'AUD - Australian Dollar',
            Preferred_Resource_Location__c = 'No preference',
            Preferred_Timezone__c = '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            Prior_Stage_Name__c = 'Drafting',
            Date_Required__c = Date.valueOf('2019-07-31'),
            Salesforce_Product__c = 'Sales Cloud',
            Environment__c = 'Sandbox',
            Sandbox_Name__c = 'BAU',
            Production_Deployment__c = 'No',
            Stage_Name__c = 'Waiting for Estimation',
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'I need help',
            Urgency__c = 'High');
        insert req;

        // Add mock response expected from polling call when a request update is available with a new Artisan question
        calloutMocks.AddMockResponse( 'GET', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     250, '"{\"AssistanceRequest\":{\"attributes\":{\"type\":\"Case\",\"url\":\"/services/data/v46.0/sobjects/Case/5000p000000tgujAAA\"},\"Id\":\"5000p000000tgujAAA\",\"Assistance_Request_Id__c\":\"' + req.Id + '\",\"Subject\":\"this one has one Artisan question\",\"SystemModstamp\":\"2019-07-31T06:23:40.000+0000\",\"Status\":\"Drafting\",\"Actual_Cost__c\":300000.00,\"Actual_End_Date__c\":\"2019-11-21\",\"Actual_Person_Days__c\":120.00,\"Actual_Start_Date__c\":\"2019-08-12\",\"Estimated_Cost__c\":250000.00,\"Estimated_End_Date__c\":\"2019-10-31\",\"Estimated_Person_Days__c\":100.00,\"Estimated_Start_Date__c\":\"2019-09-02\",\"Questions_Answers__r\":{\"totalSize\":1,\"done\":true,\"records\":[{\"attributes\":{\"type\":\"Question_Answer__c\",\"url\":\"/services/data/v46.0/sobjects/Question_Answer__c/a2O0p000000CHjfEAG\"},\"Case_Id__c\":\"5000p000000tgujAAA\",\"Id\":\"a2O0p000000CHjfEAG\",\"Name\":\"AQA00000140\",\"SystemModstamp\":\"2019-07-31T06:23:40.000+0000\",\"RecordTypeId\":\"0120p0000005iYYAAY\",\"Question__c\":\"<p>A question from Artisan</p>\",\"Asked_by_Name__c\":\"Richard Clarke\",\"Asked_by_Email__c\":\"richard.clarke@pscgroup.com.au\",\"Asked_by_Phone__c\":\"+61 61410804829\",\"RecordType\":{\"attributes\":{\"type\":\"RecordType\",\"url\":\"/services/data/v46.0/sobjects/RecordType/0120p0000005iYYAAY\"},\"Id\":\"0120p0000005iYYAAY\",\"DeveloperName\":\"Artisan_Question\"}}]}}}"', responseHeaders );

        // Set mock response
        Test.setMock(HttpCalloutMock.class, calloutMocks);
        
        // Start the test here so the callout to get updates is in a different context to the DML above
        Test.startTest();

        // Poll for changes using the scheduled batch class which calls a queuable class which calls the API
        SchedulableContext sc = null;
        AssistanceRequestSchedulableBatch sb = new AssistanceRequestSchedulableBatch();
        sb.Execute(sc);
        
        Test.stopTest();

        // There should be 1 assistance request without an Artisan case systemmodstamp and 0 questions
        List<Assistance_Request__c> reqs = [Select Id, Name, Artisan_Case_SystemModstamp__c from Assistance_Request__c readonly limit 10];
        System.assertEquals(1, reqs.size(), 'There should be 1 assistance request');
        System.assertEquals(null, reqs[0].Artisan_Case_SystemModstamp__c, 'There should be a no systemmodstamp from the update' );
        
        List<Question_Answer__c> qas = [select Id, Name, Artisan_Question_Answer_Id__c, RecordTypeId, Assistance_Request_Id__c from Question_Answer__c readonly limit 10];
        System.assertEquals(0, qas.size(), 'There should be no questions');

        // Two exceptions should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c];
        System.assertEquals(2, logRecords.size(), 'There should be two exceptions');
    }
    
    // Negative case where polling query returns an unexpected status code
    static testMethod void testPolling_RequestException(){

        // Setup to support multiple mock responses from different end points        
        ArtisanRestApiCalloutsMock calloutMocks =  new ArtisanRestApiCalloutsMock();
        Map<String, String> responseHeaders =  new Map<String, String>();
        responseHeaders.put('Content-Type', 'application/json');

        // Add mock response expected when inserting a case into the Artisan org after inserting an Assistance Request in the customer org
        calloutMocks.AddMockResponse( 'POST', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Case.Id\":\"5000p00000Dv7TnAAJ\"}', responseHeaders );

        // Set mock response
        Test.setMock(HttpCalloutMock.class, calloutMocks);
        
        // Create a request for assistance
        Assistance_Request__c req = new Assistance_Request__c(
            Description__c = 'Please help me with Salesforce',
            Login_Access__c = 'Yes',
            Preferred_Billing_Currency__c = 'AUD - Australian Dollar',
            Preferred_Resource_Location__c = 'No preference',
            Preferred_Timezone__c = '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)',
            Prior_Stage_Name__c = 'Drafting',
            Date_Required__c = Date.valueOf('2019-07-31'),
            Salesforce_Product__c = 'Sales Cloud',
            Environment__c = 'Sandbox',
            Sandbox_Name__c = 'BAU',
            Production_Deployment__c = 'No',
            Stage_Name__c = 'Waiting for Estimation',
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'I need help',
            Urgency__c = 'High');
        insert req;

        // Add mock response expected from polling call when a request update is available with a new Artisan question
        calloutMocks.AddMockResponse( 'GET', ArtisanRestApiCallouts.artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/', 
                                     200, '{\"Exception\":\"Assistance_Request_Id is required\"}', responseHeaders );

        // Set mock response
        Test.setMock(HttpCalloutMock.class, calloutMocks);
        
        // Start the test here so the callout to get updates is in a different context to the DML above
        Test.startTest();

        // Do call out to poll for updates - this will collect and create the new Artisan question
        String requestId = ArtisanRestApiCallouts.getRequestUpdates(
            '', // "Assistance_Request_Id"
            ''); // "Artisan_Case_SystemModstamp"
  
        // Return should be the Artisan org case id or null if no data was returned
        System.assertEquals(null, requestId, 'The return value should be null if an exception is returned');
        
        Test.stopTest();

        // There should be 1 assistance request without an Artisan case systemmodstamp and 0 questions
        List<Assistance_Request__c> reqs = [Select Id, Name, Artisan_Case_SystemModstamp__c from Assistance_Request__c readonly limit 10];
        System.assertEquals(1, reqs.size(), 'There should be 1 assistance request');
        System.assertEquals(null, reqs[0].Artisan_Case_SystemModstamp__c, 'There should be a no systemmodstamp from the update' );
        
        List<Question_Answer__c> qas = [select Id, Name, Artisan_Question_Answer_Id__c, RecordTypeId, Assistance_Request_Id__c from Question_Answer__c readonly limit 10];
        System.assertEquals(0, qas.size(), 'There should be no questions');

        // One exception should be logged
        List<Apex_Log__c> logRecords = [select Message__c from Apex_Log__c];
        System.assertEquals(1, logRecords.size(), 'There should be one exceptions');
    }
}