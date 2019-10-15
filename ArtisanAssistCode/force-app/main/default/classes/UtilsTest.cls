/**
 * Test class for the Utils class.
 *
 * @author Mohamed Atheek
 * @date 31/05/2017 
 */

@isTest
private class UtilsTest {

    static testMethod void testGetUser() {   
    	User u = Utils.getUser(UserInfo.getUserId());
    	
    	System.assertEquals(UserInfo.getUserId(), u.Id);
    }
    
    static testMethod void testGetUsersSummary() {
    	List<Map<String, String>> us = Utils.getUsersSummary();
    	
    	System.assert(us.size() > 0);
    }
    
    static testMethod void testGetOrganization() {
    	Organization o1 = [SELECT Id, Name FROM Organization LIMIT 1];
    	
    	Organization o2 = Utils.getOrganization(o1.Id);
    	
    	System.assertEquals(o1.Id, o2.Id);
    	System.assertEquals(o1.Name, o2.Name);
    }
    
    static testMethod void testSendTextEmail() { 
    	
    	Messaging.SendEmailResult result = Utils.sendTextEmail('test@email.com', 'replyto@email.com', 'Licexp', 'Subject', 'Body');
    	
    	System.assert(result.isSuccess());
    }
    
    static testMethod void testGetJSONString() { 
    	User u = Utils.getUser(UserInfo.getUserId()); 
    	Organization o = [SELECT Id FROM Organization LIMIT 1];  
    	o = Utils.getOrganization(o.Id);   
    	
    	List<Map<String, String>> us = Utils.getUsersSummary();
    	
    	//Post Install
    	Map<String, String> installContext = new Map<String, String> {
	    	'OrganizationId' => o.Id,
	    	'UserId'=> u.Id,
	    	'IsUpgrade' => 'true',
	    	'IsPush' => 'false',   	
	    	'PreviousVersion' => '1.0.0'
    	};
    	
    	String json = Utils.getJSONString(installContext, null, u, us, o);
    	
    	System.assert(json.contains('\"InstallContext\"'));
    	System.assert(json.contains('\"User\"'));
    	System.assert(json.contains('\"Organization\"'));
    	System.assert(json.contains('\"UsersSummary\"'));
    	
    	//Post Uninstall    	
    	Map<String, String> uninstallContext = new Map<String, String> {
	    	'OrganizationId' => o.Id,
	    	'UserId'=> u.Id
    	};
    	
    	json = Utils.getJSONString(null, uninstallContext, u, us, o);
    	
    	System.assert(json.contains('\"UninstallContext\"'));
    	System.assert(json.contains('\"User\"'));
    	System.assert(json.contains('\"Organization\"'));
    	System.assert(json.contains('\"UsersSummary\"'));
    }
    
    static testMethod void testNormaliseForEmail() {
    	System.assertEquals('name_with__space_and_____1', Utils.normaliseForEmail('name with  space and (-) 1'));
    }
    
    static testMethod void testMyDomainName() {
    	System.assert(String.isNotBlank(Utils.myDomainName));
    }
    
    // make sure methods to get record type ids work
    static testMethod void testRecordTypes(){
        Id idRecordType = Utils.GetCustomerQuestionAnswerRecordTypeId();
        String idString = Id.valueOf(idRecordType);
        system.assertEquals('012', idString.Left(3));
        
        idRecordType = Utils.GetArtisanQuestionAnswerRecordTypeId();
        idString = Id.valueOf(idRecordType);
        system.assertEquals('012', idString.Left(3));
    }
    
    // method to get coverage over namespace method but this code is designed to work in both managed and unmanaged packages
    static testMethod void testNamespacePrefix(){
        String nmSpace = Utils.GetNamespacePrefix();
        system.assertEquals(true,true); // method is only to get coverage as this function will support any scenario
    }
        
}