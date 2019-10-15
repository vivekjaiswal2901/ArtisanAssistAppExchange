/**
 * Test class for the PackageUninstallHandler class.
 *
 * @author Richard Clarke based on prior work by Mohamed Atheek
 * @10/07/2019
 */

@isTest
private class PackageUninstallHandlerTest {

    static testMethod void testUninstallHandler() {
    	try {
            Test.startTest();
        	Test.testUninstall(new PackageUninstallHandler());
            test.stopTest();
    	} catch (Exception e) {
    		System.assert(false, 'Package Uninstall scripts should not throw errors [' + e.getMessage() + ']');
    	}
    }
}