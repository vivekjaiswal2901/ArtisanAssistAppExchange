/**
 * Artisan Assist Package uninstall handler class that is executed after the package is uninstalled in the customer org.
 * Emails customer org details to package owner.
 *
 * Note install handlers cannot throw exceptions
 * https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_uninstall_handler.htm
 * Any failures will not stop uninstallation but any changes are rolled back
 * Is not allowed to do callouts so whilst the API class has a method to support uninstall that is not callable from here
 * Future task is to send an email to an Artisan email handler rather than artisan.assistance to update the account to installed
 * 
 * Test anonymously with:
 
 		UninstallContext cx = null;
 		PackageUninstallHandler pg = new PackageUninstallHandler();
 		pg.onUninstall(cx);

 * @author Richard Clarke based on prior work by Mohamed Atheek
 * @date 10/07/2019
 */

global class PackageUninstallHandler implements UninstallHandler {
	
    private Id userId;
    private Id orgId;
	private String currentVersion;
    
    global void onUninstall(UninstallContext context) {
        
		// If System.requestVersion is not run in a managed package "System.ProcedureException: Method is not supported from an unmanaged namespace"
        if (( context != null ) && Utils.isManaged()) {
            // Running in managed package in a proper install context
        	currentVersion =  System.requestVersion().major() + '.' + System.requestVersion().minor();
            userId = context.uninstallerId();
            orgId = context.organizationId();
        } else {
            // Running unmanaged not in a managed package install context
        	currentVersion = 'Unmanaged';
            userId = UserInfo.getUserId();
            orgId = userInfo.getOrganizationId();
        }

        // See if the polling jobs are still running and terminate if they are - exception handler masks exceptions as uninstall cannot throw an exception
        try {
            List<CronTrigger> pollingJobs = [SELECT Id, CronJobDetailId, NextFireTime, State FROM CronTrigger WHERE CronJobDetail.JobType = '7' AND CronJobDetail.Name like :AssistanceRequestSchedulableBatch.ArtisanAssistancePollingJobName + '%'];
            for ( CronTrigger pollJob : pollingJobs ) {	
                system.abortJob(pollJob.Id);
            }
        } catch ( Exception e ){
        }

        // Report the uninstall
		User u = Utils.getUser(userId);
		Organization o = Utils.getOrganization(orgId);
        
        Map<String, String> uninstallContext = new Map<String, String>();
        uninstallContext.put('OrganizationId', orgId);
        uninstallContext.put('UserId', userId);
        uninstallContext.put('CurrentVersion', currentVersion);
        uninstallContext.put('Date', System.now().format('yyyy-MM-dd'));
        
        String emailBody = Utils.getJSONString(null, uninstallContext, u, null, o);
        String subject = String.format('{0} has just uninstalled Artisan Assistance {1} in the {2} org named {3}', new List<String>{u.Name, currentVersion, o.OrganizationType, o.Name});
        
        //system.debug('*** In PackageUninstallHandler.onUninstall and about to send email to artisan.assistance@pscgroup.com.au, subject=' + subject + ', emailBody=' + emailBody);
        // Send email to Artisan confirming the install but do it in an exception handler to cover situations like sandbox with email send disallowed
        try {
	        Utils.sendArtisanAssistanceTextEmail( subject, emailBody );
        } catch ( Exception e ) {
            // Do nothing on uninstall failure to send email as can't log to custom object
            // LogUtils.log(e, 'Failed to send email to Artisan during uninstall');
        }
	}
}