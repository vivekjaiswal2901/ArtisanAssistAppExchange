/*
 * Test class for LogUtils
 *
 * @author Richard Clarke (based on prior work by Mohamed Atheek)
 * @date 15/07/2017 
 */
@isTest
private class LogUtilsTest {
	
	static testMethod void testDebugLog_Log() {
    	
        Test.startTest();
        LogUtils.log('Message1', 100, PackageInstallHandler.class);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT count() FROM Apex_Log__c]);
	}
    
    class TestException extends Exception {}
    
    static testMethod void testErrorLog_LogEnabled() {
    	
    	Integer line1, line2, line3;
    	
        try {
        	throw new TestException('Message1');
        } catch (Exception e) {
        	line1 = e.getLineNumber();
        	LogUtils.addLog(e);
        }
        
        try {
        	throw new TestException('Message2');
        } catch (Exception e) {
        	line2 = e.getLineNumber();
        	LogUtils.addLog(e);
        }
        
        try {
        	throw new TestException('Message3');
        } catch (Exception e) {
        	line3 = e.getLineNumber();
        	LogUtils.addLog(e);
        }
        
        Test.startTest();

        LogUtils.commitLogsAsync();
        
        Test.stopTest();
        
        Apex_Log__c log1 = [SELECT Message__c, Line_Number__c, Log_Type__c, Exception_Type__c, Stack_Trace__c
        					FROM Apex_Log__c
        					WHERE Line_Number__c = :line1];
        System.assertEquals('Message1', log1.Message__c);
        System.assertEquals('LogUtilsTest.TestException', log1.Exception_Type__c.right(26));
        System.assertNotEquals(null, log1.Stack_Trace__c);
        System.assertEquals('ERROR', log1.Log_Type__c);
        
        Apex_Log__c log2 = [SELECT Message__c, Line_Number__c, Log_Type__c, Exception_Type__c, Stack_Trace__c
        					FROM Apex_Log__c
        					WHERE Line_Number__c = :line2];
        System.assertEquals('Message2', log2.Message__c);
        System.assertEquals('LogUtilsTest.TestException', log2.Exception_Type__c.right(26));
        System.assertNotEquals(null, log2.Stack_Trace__c);
        System.assertEquals('ERROR', log2.Log_Type__c);
        
        Apex_Log__c log3 = [SELECT Message__c, Line_Number__c, Log_Type__c, Exception_Type__c, Stack_Trace__c
        					FROM Apex_Log__c
        					WHERE Line_Number__c = :line3];
        System.assertEquals('Message3', log3.Message__c);
        System.assertEquals('LogUtilsTest.TestException', log3.Exception_Type__c.right(26));
        System.assertNotEquals(null, log3.Stack_Trace__c);
        System.assertEquals('ERROR', log3.Log_Type__c);
    }
    
    static testMethod void testErrorLog() {
    	Integer line1, line2, line3;
    	
        Test.startTest();

        try {
        	throw new TestException('Message1');
        } catch (Exception e) {
        	line1 = e.getLineNumber();
        	LogUtils.log(e);
        }
        
        Test.stopTest();
        
        Apex_Log__c log1 = [SELECT Message__c, Line_Number__c, Log_Type__c, Exception_Type__c, Stack_Trace__c
        					FROM Apex_Log__c
        					WHERE Line_Number__c = :line1];
        System.assertEquals('Message1', log1.Message__c);
        System.assertEquals('LogUtilsTest.TestException', log1.Exception_Type__c.right(26));
        System.assertNotEquals(null, log1.Stack_Trace__c);
        System.assertEquals('ERROR', log1.Log_Type__c);
    }
    
    static testMethod void testLimitChars() {    	
    	System.assertEquals(null, LogUtils.limitChars(null, 10));
    	System.assertEquals('', LogUtils.limitChars('abc', -1));
    	System.assertEquals('', LogUtils.limitChars('abc', 0));
    	System.assertEquals('a', LogUtils.limitChars('abc', 1));
    	System.assertEquals('abc', LogUtils.limitChars('abc', 10));
    	System.assertEquals('abcdefghijklmnopqrstuvwxyz', LogUtils.limitChars('abcdefghijklmnopqrstuvwxyz', 26));
    	System.assertEquals('abcdefghijklmnopqrstuvwxy', LogUtils.limitChars('abcdefghijklmnopqrstuvwxyz', 25));
    }
}