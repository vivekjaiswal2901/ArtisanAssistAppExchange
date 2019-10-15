/**
 * Artisan Assist package install handler class that is executed after 
 * the package is installed in the customer org.  The classes extracts data
 * about the customer org and sends that to PS+C Artisan.
 * 
 * Note install handlers cannot throw exceptions
 *
 * Data is sent to Artisan's org by API call and by email.  The API call is async and after the commit as per
 * https://developer.salesforce.com/docs/atlas.en-us.packagingGuide.meta/packagingGuide/apex_post_install_script.htm
 * Any failures will prevent installation
 * 
 * The class also schedules the Apex batch job to poll the PS+C Artisan org for data
 * updates
 * 
 * Test anonymously with:
 
 		InstallContext cx = null;
 		PackageInstallHandler pg = new PackageInstallHandler();
 		pg.onInstall(cx);

 * @author Richard Clarke (based on earlier version by Mohamed Atheek)
 * @date 10/07/2019
 */

global class PackageInstallHandler implements InstallHandler {
	
    private Id userId;
    private Id orgId;
	private String currentVersion;
	private String previousVersion;
    private Boolean isUpgrade;
    private Boolean isPush;
    private Boolean isManagedPackageInstallation;

    global void onInstall(InstallContext context) {	
        
        // If System.requestVersion is not run in a managed package "System.ProcedureException: Method is not supported from an unmanaged namespace" is thrown
        if (( context != null ) && Utils.isManaged()) {
            // Running in managed package in a proper install context
        	currentVersion =  (System.requestVersion() != null) ? System.requestVersion().major() + '.' + System.requestVersion().minor() : 'Not known';
            previousVersion = (context.previousVersion() != null) ? context.previousVersion().major() + '.' + context.previousVersion().minor() + '.' + context.previousVersion().patch() : 'Not known';
            userId = context.installerId();
            orgId = context.organizationId();
            isUpgrade = context.isUpgrade();
            isPush = context.isPush();
            isManagedPackageInstallation = true;
        } else {
            // Running unmanaged not in a managed package install context
        	currentVersion = 'Not known';
            previousVersion = 'Not known';
            userId = UserInfo.getUserId();
            orgId = userInfo.getOrganizationId();
            isUpgrade = false;
            isPush = false;
           	isManagedPackageInstallation = false;
        }
        
        User u = Utils.getUser(userId);
		Organization o = Utils.getOrganization(orgId);
		List<Map<String, String>> userLicenseMatrix = Utils.getUsersSummary();

        // Prepare for call out to send the user license matrix back as pretty JSON
    	JSONGenerator gen = JSON.createGenerator(true);
    	gen.writeStartObject();
        gen.writeFieldName('UsersSummary');
    	gen.writeObject(userLicenseMatrix);
    	gen.writeEndObject();
    	String userLicenseMatrixJSON = gen.getAsString();	

        // Send the data to Artisan to indicate the app has been installed - do this by REST API and with email sent as a backup
        // Callouts are only allowed in an install script if async and the script is not allowed to throw exceptions
        ArtisanRestApiCallouts.packageInstalled(
            currentVersion,
            
            o.City,
            o.Country,
            o.DefaultLocaleSidKey,
        	Utils.myDomainName,
        	orgId,
            o.InstanceName,
            String.valueOf(o.IsSandbox),
            o.LanguageLocaleKey,
            o.Name,
        	o.Phone,
            o.PostalCode,
            o.PrimaryContact,
            o.State,
            o.Street,
            o.OrganizationType,
            userLicenseMatrixJSON,

            u.Id,
            u.Title,
            u.FirstName,
            u.LastName,
            u.Email,
            u.Phone,
            u.MobilePhone,
            u.Street,
            u.City,
            u.State,
            u.PostalCode,
            u.Country);
        
        // Also send by email as a backup for the API not working
        Map<String, String> installContext = new Map<String, String>();
        installContext.put('OrganizationId', orgId);
        installContext.put('DomainName', Utils.myDomainName);
        installContext.put('InstallerUserId', userId);
        installContext.put('IsUpgrade', String.valueOf(isUpgrade));
        installContext.put('IsPush', String.valueOf(isPush));
        installContext.put('CurrentVersion', currentVersion);
        installContext.put('PreviousVersion', previousVersion);
        installContext.put('Date', System.now().format('yyyy-MM-dd'));
        
        String emailBody = Utils.getJSONString(installContext, null, u, userLicenseMatrix, o);
        String subject = !isUpgrade ? '{0} has just installed Artisan Assistance {1} in the {2} org named {3}' : '{0} has just updated Artisan Assistance {1} in the {2} org named {3}';
        subject = String.format(subject, new List<String>{u.Name, currentVersion, o.OrganizationType, o.Name});
        
        //system.debug('*** In Artisan Assistance PackageInstallHandler.onInstall and about to send email to artisan.assistance@pscgroup.com.au, subject=' + subject);
        // Send email to Artisan confirming the install but do it in an exception handler to cover situations like sandbox with email send disallowed
        try {
        	Utils.sendArtisanAssistanceTextEmail( subject, emailBody );
        } catch ( Exception e ) {
            LogUtils.log(e, 'Failed to send email to Artisan during installation');
        }

        // See if the polling job is running to avoid starting a second set - do this last as the scheduling creates data so have to occur after the callout
        List<CronTrigger> pollingJobs = [SELECT Id, CronJobDetailId, NextFireTime, State FROM CronTrigger WHERE CronJobDetail.JobType = '7' AND CronJobDetail.Name like :AssistanceRequestSchedulableBatch.ArtisanAssistancePollingJobName + '%'];
        if (pollingJobs.size() == 0) {	
            // It is not running so schedule to run every 15 minutes
            system.schedule(AssistanceRequestSchedulableBatch.ArtisanAssistancePollingJobName + ':00', '0 0 * * * ?', new AssistanceRequestSchedulableBatch());
            system.schedule(AssistanceRequestSchedulableBatch.ArtisanAssistancePollingJobName + ':15', '0 15 * * * ?', new AssistanceRequestSchedulableBatch());
            system.schedule(AssistanceRequestSchedulableBatch.ArtisanAssistancePollingJobName + ':30', '0 30 * * * ?', new AssistanceRequestSchedulableBatch());
            system.schedule(AssistanceRequestSchedulableBatch.ArtisanAssistancePollingJobName + ':45', '0 45 * * * ?', new AssistanceRequestSchedulableBatch());
        }
    }
}