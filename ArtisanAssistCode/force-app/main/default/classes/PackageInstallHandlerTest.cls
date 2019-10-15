/**
 * Test class for the PackageInstallHandler class
 *
 * @author Richard Clarke based on prior work by Mohamed Atheek
 * @date 10/07/2019 
 */
 
@isTest
private class PackageInstallHandlerTest {
    
    static testMethod void testInstallHandler() {
    	try {
            Test.startTest();
	    	Test.testInstall(new PackageInstallHandler(), null);
	    	Test.testInstall(new PackageInstallHandler(), new Version(1, 2, 3), true);
            test.stopTest();
    	} catch (Exception e) {
    		System.assert(false, 'Package Uninstall scripts should not throw errors [' + e.getMessage() + ']');
    	}

        // Check jobs are running
//		System.assertEquals(4, [SELECT count() FROM CronJobDetail WHERE CronJobDetail.JobType = '7' AND CronJobDetail.Name like :AssistanceRequestSchedulableBatch.ArtisanAssistancePollingJobName + '%']);
    }
}