/**
 * Artisan Assistance class to test AssistanceRequestController.cls
 *
 * @author Michael Witchalls
 * @date 18/10/2019
 */       
@IsTest
private class AssistanceRequestControllerTest { 
	private static final String TIMEZONE = '(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)';
	private static final String AUDCURRENCY = 'AUD - Australian Dollar';
    private static final String DRAFTING = 'Drafting';
    private static final String ESTIMATION = 'Waiting for Estimation';
    private static final String PRODNAME = 'Sales Cloud';

	@testSetup static void setupTestData() {
        
        // Create a new request for assistance
        Assistance_Request__c req = new Assistance_Request__c(
            Description__c = 'I need some help',
            Login_Access__c = 'Yes',
            Preferred_Billing_Currency__c = AUDCURRENCY,
            Preferred_Resource_Location__c = 'No preference',
            Preferred_Timezone__c = TIMEZONE,
            Prior_Stage_Name__c = null,
            Date_Required__c = Date.today().addMonths(1),
            Salesforce_Product__c = PRODNAME,
            Sandbox_Name__c = null,
            Stage_Name__c = DRAFTING,
            Success_Criteria__c = 'So I will know what to do',
            Title__c = 'Please help me',
            Urgency__c = 'Medium' 
        );
        insert req;

 	}    

    @isTest 
    static void testit() {
        Assistance_Request__c req1 = [SELECT Id FROM  Assistance_Request__c];
        String arId = req1.Id;

        Test.startTest();

        Assistance_Request__c req = AssistanceRequestController.getAssistanceRequest(arId);

        AssistanceRequestController.setNewStageNameApex(arId, ESTIMATION);

        AssistanceRequestController.pollArtisanNowApex(arId);
        AssistanceRequestController.getNameSpace();
        
        Test.stopTest();

        system.assertEquals(DRAFTING, req.Stage_Name__c);
        Assistance_Request__c req2 = [SELECT Id, Stage_Name__c FROM  Assistance_Request__c];    
        system.assertEquals(ESTIMATION, req2.Stage_Name__c);
    }  
    
}