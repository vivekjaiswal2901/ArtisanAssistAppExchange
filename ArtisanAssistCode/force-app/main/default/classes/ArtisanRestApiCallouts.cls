/**
 * Artisan Assist class to handle all callouts to the Artisan Production Org
 *
 * @author Richard Clarke
 * @date 15/07/2019
 */
public without sharing class ArtisanRestApiCallouts {

    // Define the header to be carried in the HTTP method calls under TLS to avoid anyone seeing it
	static private String artisanAssistanceAppKey = '19b7543ca346038fcd9dc29a4e85a91e'; // MD5 hash of ArtisanAssistanceAppV1AppKey from https://www.md5hashgenerator.com/

    // Define the remote site URL (needs to be configured as an authorised remote site)
    // Customer orgs and the golden packaging org and the beta packaging org all point to production
    // Others point to the Artisan sandbox hosting the non-production endpoints
    public static String artisanAssistanceRestApiHost {
        get {
            String nameSpace = Utils.GetNamespacePrefix();
            if (( nameSpace == 'assist' ) || ( nameSpace == 'assistbeta' ))
                return 'https://api.artisans.com.au';
            else
            	return 'https://assistdev-artisan-api.cs74.force.com';
        }
        private set;
    }

    // Add a field to the JSON structure catering for null
    private static void WriteJsonField( JSONGenerator gen, String fieldName, String fieldValue ){
        gen.writeFieldName(fieldName);
        if ( !String.isBlank(fieldValue) ){
        	gen.writeObject(fieldValue);
        } else {
            // Caters for null values which avoids "null argument for JSONGenerator.writeObject()"
        	gen.writeObject('');
        }
    }
        
    // Parse a JSON return value from a REST method and extract the Id (return null if exception), expected options are a single id or a single exception
    // "{\"Account.Id\":\"0010p00000Dv7TnAAJ\"}"
    // "{\"Exception\":\"Customer_Org_Id is the wrong length [00D12341234123]\"}"
    private static String ExtractIdFromJson( String jsonReturnValue ){
        String returnValue = null;
        try {
            if ( jsonReturnValue.left(1) == '\"' ){
                jsonReturnValue = jsonReturnValue.mid(1, jsonReturnValue.length()-2).unescapeJava();
            }
            JSONParser parser = JSON.createParser(jsonReturnValue);
            parser.nextToken();
            parser.nextValue();
            String jsonFieldName = parser.getCurrentName();
            if (( jsonFieldName != null ) && ( jsonFieldName.Right(3) == '.Id' )){
                returnValue = parser.getText();
            }
        } catch (Exception e){
        }
		return returnValue;
    }

    private static String ExtractExceptionFromJson( String jsonReturnValue ){
        String returnValue = null;
        try {
            if ( jsonReturnValue.left(1) == '\"' ){
                jsonReturnValue = jsonReturnValue.mid(1, jsonReturnValue.length()-2).unescapeJava();
            }
            JSONParser parser = JSON.createParser(jsonReturnValue);
            parser.nextToken();
            parser.nextValue();
            String jsonFieldName = parser.getCurrentName();
            if (( jsonFieldName != null ) && ( jsonFieldName == 'Exception' )){
                returnValue = parser.getText();
            }
        } catch (Exception e){
        }
		return returnValue;
    }

    // Callout to inform Artisan's production org that the Artisan Assistance App has been installed
    // CANNOT throw exceptions as called during the package install process
    // If the callout was successful returns the id of the created/updated account e.g. 0010p00000Du0N7AAJ otherwise null
    // HttpPost request should be like this
    /*
	{
		"Artisan_Assistance_App_Version" : "Undefined",

		"Customer_Org_City" : "Melbourne",
		"Customer_Org_Country" : "Australia",
		"Customer_Org_DefaultLocaleSidKey" : "en_AU",
		"Customer_Org_DomainName" : "artisan-assistance-dev-ed",
		"Customer_Org_Id" : "00D123412341234",
		"Customer_Org_InstanceName" : "AP15",
		"Customer_Org_IsSandbox" : "No",
		"Customer_Org_LanguageLocaleKey" : "(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)",
		"Customer_Org_Name" : "Postman Artisan Assistance Package Install",
		"Customer_Org_Phone" : "+61 3 8592 9000",
		"Customer_Org_Postalcode" : "3000",
		"Customer_Org_Primary_Contact" : "Installer Clarke",
		"Customer_Org_State" : "VIC",
		"Customer_Org_Street" : "L10, 410 Collins St",
		"Customer_Org_Type" : "Enterprise",
		"Customer_Org_User_License_Summary" : "JSON here for licenses",

		"Artisan_Assistance_Installer_User_Id" : "0052v00000ZtzY0",
		"Artisan_Assistance_Installer_User_Title" : "National Salesforce Practice Director",
		"Artisan_Assistance_Installer_User_FirstName" : "Installer",
		"Artisan_Assistance_Installer_User_LastName" : "Clarke",
		"Artisan_Assistance_Installer_User_Email" : "richard.clarke@pscgroup.com.au",
		"Artisan_Assistance_Installer_User_Phone" : "+61 3 8592 9000",
		"Artisan_Assistance_Installer_User_Mobile" : "+61 410 804 829",
		"Artisan_Assistance_Installer_User_Street" : "L11, 410 Collins St",
		"Artisan_Assistance_Installer_User_City" : "Melbourne",
		"Artisan_Assistance_Installer_User_State" : "Vic",
		"Artisan_Assistance_Installer_User_Postalcode" : "3000",
		"Artisan_Assistance_Installer_User_Country" : "Australia"
	}
     */
    //
    //  Can be tested with this anonymous Apex
    //  
    /*
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
		system.debug('*** returned account id = ' + aId);
	*/
    @future (callout=true)
    public static void packageInstalled(
        String Artisan_Assistance_App_Version,
        
        String Customer_Org_City,
        String Customer_Org_Country,
        String Customer_Org_DefaultLocaleSidKey,
        String Customer_Org_DomainName,
        String Customer_Org_Id,
        String Customer_Org_InstanceName,
        String Customer_Org_IsSandbox,
        String Customer_Org_LanguageLocaleKey,
        String Customer_Org_Name,
        String Customer_Org_Phone,
        String Customer_Org_Postalcode,
        String Customer_Org_Primary_Contact,
        String Customer_Org_State,
        String Customer_Org_Street,
        String Customer_Org_Type,
        String Customer_Org_User_License_Summary,
        
        String Artisan_Assistance_Installer_User_Id,
        String Artisan_Assistance_Installer_User_Title,
        String Artisan_Assistance_Installer_User_FirstName,
        String Artisan_Assistance_Installer_User_LastName,
        String Artisan_Assistance_Installer_User_Email,
        String Artisan_Assistance_Installer_User_Phone,
        String Artisan_Assistance_Installer_User_Mobile,
        String Artisan_Assistance_Installer_User_Street,
        String Artisan_Assistance_Installer_User_City,
        String Artisan_Assistance_Installer_User_State,
        String Artisan_Assistance_Installer_User_Postalcode,
        String Artisan_Assistance_Installer_User_Country
    ){
        Id returnedAccountId = null;

        try {
            // Create the JSON request body (non-pretty) based on the parameters
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
    	    	
            WriteJsonField(gen, 'Artisan_Assistance_App_Version', Artisan_Assistance_App_Version);
            
	    	WriteJsonField(gen, 'Customer_Org_City', Customer_Org_City);
	    	WriteJsonField(gen, 'Customer_Org_Country', Customer_Org_Country);
	    	WriteJsonField(gen, 'Customer_Org_DefaultLocaleSidKey', Customer_Org_DefaultLocaleSidKey);
	    	WriteJsonField(gen, 'Customer_Org_DomainName', Customer_Org_DomainName);
	    	WriteJsonField(gen, 'Customer_Org_Id', Customer_Org_Id);
            WriteJsonField(gen, 'Customer_Org_InstanceName', Customer_Org_InstanceName);
            WriteJsonField(gen, 'Customer_Org_IsSandbox', Customer_Org_IsSandbox);
            WriteJsonField(gen, 'Customer_Org_LanguageLocaleKey', Customer_Org_LanguageLocaleKey);
            WriteJsonField(gen, 'Customer_Org_Name', Customer_Org_Name);
            WriteJsonField(gen, 'Customer_Org_Phone', Customer_Org_Phone);
            WriteJsonField(gen, 'Customer_Org_Postalcode', Customer_Org_Postalcode);
            WriteJsonField(gen, 'Customer_Org_Primary_Contact', Customer_Org_Primary_Contact);
            WriteJsonField(gen, 'Customer_Org_State', Customer_Org_State);
            WriteJsonField(gen, 'Customer_Org_Street', Customer_Org_Street);
            WriteJsonField(gen, 'Customer_Org_Type', Customer_Org_Type);
            WriteJsonField(gen, 'Customer_Org_User_License_Summary', Customer_Org_User_License_Summary);

            WriteJsonField(gen, 'Artisan_Assistance_Installer_User_Id', Artisan_Assistance_Installer_User_Id);
            WriteJsonField(gen, 'Artisan_Assistance_Installer_User_Title', Artisan_Assistance_Installer_User_Title);
            WriteJsonField(gen, 'Artisan_Assistance_Installer_User_FirstName', Artisan_Assistance_Installer_User_FirstName);
            WriteJsonField(gen, 'Artisan_Assistance_Installer_User_LastName', Artisan_Assistance_Installer_User_LastName);
            WriteJsonField(gen, 'Artisan_Assistance_Installer_User_Email', Artisan_Assistance_Installer_User_Email);
            WriteJsonField(gen, 'Artisan_Assistance_Installer_User_Phone', Artisan_Assistance_Installer_User_Phone);
            WriteJsonField(gen, 'Artisan_Assistance_Installer_User_Mobile', Artisan_Assistance_Installer_User_Mobile);
            WriteJsonField(gen, 'Artisan_Assistance_Installer_User_Street', Artisan_Assistance_Installer_User_Street);
            WriteJsonField(gen, 'Artisan_Assistance_Installer_User_City', Artisan_Assistance_Installer_User_City);
            WriteJsonField(gen, 'Artisan_Assistance_Installer_User_State', Artisan_Assistance_Installer_User_State);
            WriteJsonField(gen, 'Artisan_Assistance_Installer_User_Postalcode', Artisan_Assistance_Installer_User_Postalcode);
            WriteJsonField(gen, 'Artisan_Assistance_Installer_User_Country', Artisan_Assistance_Installer_User_Country);

            gen.writeEndObject();

            // Setup for the callout
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(artisanAssistanceRestApiHost + '/api/services/apexrest/ArtisanAssistanceApp/v1/');
            request.setMethod('POST');
            request.setHeader('ArtisanAssistanceAppKey', artisanAssistanceAppKey);
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Accept', 'application/json');

            // Make the request and parse the response
            request.setBody(gen.getAsString());
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
                // Unexpected response status code
                Logutils.log('The status code returned to ArtisanRestApiCallouts.packageInstalled was unexpected [' +
                    response.getStatusCode() + ' ' + response.getStatus() + ']', 232, ArtisanRestApiCallouts.class);
            } else {
                String jsonReturnValue = response.getBody();
             	returnedAccountId = ExtractIdFromJson(jsonReturnValue);
                String exceptionMessage = ExtractExceptionFromJson(jsonReturnValue);
                if ( exceptionMessage != null ){
                    // Exception return
                    Logutils.log('The callout to ArtisanRestApiCallouts.packageInstalled returned an exception [' +
                        jsonReturnValue + ']', 241, ArtisanRestApiCallouts.class);
                }
            }    
        }  catch ( Exception e ) {
            Logutils.log(e, 'Exception in ArtisanRestApiCallouts.packageInstalled [' + e.getMessage() + ']');
        } 
    }
    
    // Callout to inform Artisan's production org that the Artisan Assistance App has been uninstalled
    // CANNOT throw exceptions as called during the package uninstall process
    // If the callout was successful returns the id of the updated account e.g. 0010p00000Du0N7AAJ otherwise null
    // Http Patch request should be like this
    /*
	{
		"Customer_Org_Id" : "00d123412341234",

		"Artisan_Assistance_Uninstaller_User_Id" : "0052v00000XtzY0",
		"Artisan_Assistance_Uninstaller_User_Title" : "National Salesforce Practice Director",
		"Artisan_Assistance_Uninstaller_User_FirstName" : "Uninstaller",
		"Artisan_Assistance_Uninstaller_User_LastName" : "Clarke",
		"Artisan_Assistance_Uninstaller_User_Email" : "richard.clarke@pscgroup.com.au",
		"Artisan_Assistance_Uninstaller_User_Phone" : "+61 3 8592 9000",
		"Artisan_Assistance_Uninstaller_User_Mobile" : "+61 410 804 829",
		"Artisan_Assistance_Uninstaller_User_Street" : "L11, 410 Collins St",
		"Artisan_Assistance_Uninstaller_User_City" : "Melbourne",
		"Artisan_Assistance_Uninstaller_User_State" : "Vic",
		"Artisan_Assistance_Uninstaller_User_Postalcode" : "3000",
		"Artisan_Assistance_Uninstaller_User_Country" : "Australia"
	}
     */
    //
    //  Can be tested with this anonymous Apex
    //  
    /*
    ArtisanRestApiCallouts.packageUninstalled(
		'00d123412341234',

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
		system.debug('*** returned account id = ' + aId);
	*/
    @future (callout=true)
    public static void packageUninstalled(
        String Customer_Org_Id,
        
        String Artisan_Assistance_Uninstaller_User_Id,
        String Artisan_Assistance_Uninstaller_User_Title,
        String Artisan_Assistance_Uninstaller_User_FirstName,
        String Artisan_Assistance_Uninstaller_User_LastName,
        String Artisan_Assistance_Uninstaller_User_Email,
        String Artisan_Assistance_Uninstaller_User_Phone,
        String Artisan_Assistance_Uninstaller_User_Mobile,
        String Artisan_Assistance_Uninstaller_User_Street,
        String Artisan_Assistance_Uninstaller_User_City,
        String Artisan_Assistance_Uninstaller_User_State,
        String Artisan_Assistance_Uninstaller_User_Postalcode,
        String Artisan_Assistance_Uninstaller_User_Country
    ){
        Id returnedAccountId = null;

        try {
            // Create the JSON request body (non-pretty) based on the parameters
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
    	    	
	    	WriteJsonField(gen, 'Customer_Org_Id', Customer_Org_Id);

            WriteJsonField(gen, 'Artisan_Assistance_Uninstaller_User_Id', Artisan_Assistance_Uninstaller_User_Id);
            WriteJsonField(gen, 'Artisan_Assistance_Uninstaller_User_Title', Artisan_Assistance_Uninstaller_User_Title);
            WriteJsonField(gen, 'Artisan_Assistance_Uninstaller_User_FirstName', Artisan_Assistance_Uninstaller_User_FirstName);
            WriteJsonField(gen, 'Artisan_Assistance_Uninstaller_User_LastName', Artisan_Assistance_Uninstaller_User_LastName);
            WriteJsonField(gen, 'Artisan_Assistance_Uninstaller_User_Email', Artisan_Assistance_Uninstaller_User_Email);
            WriteJsonField(gen, 'Artisan_Assistance_Uninstaller_User_Phone', Artisan_Assistance_Uninstaller_User_Phone);
            WriteJsonField(gen, 'Artisan_Assistance_Uninstaller_User_Mobile', Artisan_Assistance_Uninstaller_User_Mobile);
            WriteJsonField(gen, 'Artisan_Assistance_Uninstaller_User_Street', Artisan_Assistance_Uninstaller_User_Street);
            WriteJsonField(gen, 'Artisan_Assistance_Uninstaller_User_City', Artisan_Assistance_Uninstaller_User_City);
            WriteJsonField(gen, 'Artisan_Assistance_Uninstaller_User_State', Artisan_Assistance_Uninstaller_User_State);
            WriteJsonField(gen, 'Artisan_Assistance_Uninstaller_User_Postalcode', Artisan_Assistance_Uninstaller_User_Postalcode);
            WriteJsonField(gen, 'Artisan_Assistance_Uninstaller_User_Country', Artisan_Assistance_Uninstaller_User_Country);

            gen.writeEndObject();

            // Setup for the callout
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(artisanAssistanceRestApiHost + '/api/services/apexrest/ArtisanAssistanceApp/v1/');
            request.setMethod('PUT');
            request.setHeader('ArtisanAssistanceAppKey', artisanAssistanceAppKey);
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Accept', 'application/json');

            // Make the request and parse the response
            request.setBody(gen.getAsString());
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
                Logutils.log('The status code returned to ArtisanRestApiCallouts.packageUninstalled was unexpected [' +
                    response.getStatusCode() + ' ' + response.getStatus() + ']', 349, ArtisanRestApiCallouts.class);
            } else {
                String jsonReturnValue = response.getBody();
                returnedAccountId = ExtractIdFromJson(jsonReturnValue);
                String exceptionMessage = ExtractExceptionFromJson(jsonReturnValue);
                if ( exceptionMessage != null ){
                    // Exception return
                    Logutils.log('The callout to ArtisanRestApiCallouts.packageUninstalled returned an exception [' +
                        jsonReturnValue + ']', 358, ArtisanRestApiCallouts.class);
                }
            }    
        } catch ( Exception e ) {
            Logutils.log(e, 'Exception in ArtisanRestApiCallouts.packageUninstalled');
        }
    }

    // Callout to inform Artisan's production org that an Assistance Request has been created
    // If the callout was successful returns the id of the created Case e.g. 500123123123123123 otherwise null
    // HttpPost request should be like this
    /*
	{
        "Assistance_Request_Id" : "a00123123123123",
        "Assistance_Request_Name" : "REQ1234",
        "Assistance_Request_Stage_Name" : "Waiting for Estimation",
        "Assistance_Request_Prior_Stage_Name" : "Drafting",
        "Assistance_Request_Status" : "Active",
        "Assistance_Request_Title" : "I need help",
        "Assistance_Request_Description" : "Please help me with Salesforce",
        "Assistance_Request_Success_Criteria" : "So I can solve my problem",
        "Assistance_Request_Urgency" : "High",
        "Assistance_Request_Date_Required" : "2019-07-31",
        "Assistance_Request_Environment" : "Sandbox",
        "Assistance_Request_Login_Access" : "Yes",
        "Assistance_Request_Production_Deployment" : "No",
        "Assistance_Request_Sandbox_Name" : "BAU",
        "Assistance_Request_Salesforce_Product" : "Sales Cloud",
        "Assistance_Request_Preferred_Resource_Location" : "No preference",
        "Assistance_Request_Preferred_Billing_Currency" : "AUD - Australian Dollar",
        "Assistance_Request_Preferred_Timezone" : "(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)",
        
        "Artisan_Request_Creator_User_Id" : "0052v00000ZtzZ0",
        "Artisan_Request_Creator_User_Title" : "Mr",
        "Artisan_Request_Creator_User_FirstName" : "Request",
        "Artisan_Request_Creator_User_LastName" : "Creator",
        "Artisan_Request_Creator_User_Email" : "richard.clarke@pscgroup.com.au",
        "Artisan_Request_Creator_User_Phone" : "+61 3 8592 9000",
        "Artisan_Request_Creator_User_Mobile" : "+61 410 804 829",
        "Artisan_Request_Creator_User_Street" : "L11, 410 Collins St",
        "Artisan_Request_Creator_User_City" : "Melbourne",
        "Artisan_Request_Creator_User_State" : "Vic",
        "Artisan_Request_Creator_User_Postalcode" : "3000",
        "Artisan_Request_Creator_User_Country" : "Australia"
	}
	*/
    //
    //  Can be tested with this anonymous Apex
    //  
    /*
    Id caseId = ArtisanRestApiCallouts.insertAssistanceRequest(
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
	system.debug('*** returned case id = ' + caseId);
	*/
    public static Id insertAssistanceRequest(
        String Assistance_Request_Id,
        String Assistance_Request_Name,
        String Assistance_Request_Stage_Name,
        String Assistance_Request_Prior_Stage_Name,
        String Assistance_Request_Phase,
        String Assistance_Request_Title,
        String Assistance_Request_Description,
        String Assistance_Request_Success_Criteria,
        String Assistance_Request_Urgency,
        String Assistance_Request_Date_Required,
        String Assistance_Request_Environment,
        String Assistance_Request_Login_Access,
        String Assistance_Request_Production_Deployment,
        String Assistance_Request_Sandbox_Name,
        String Assistance_Request_Salesforce_Product,
        String Assistance_Request_Preferred_Resource_Location,
        String Assistance_Request_Preferred_Billing_Currency,
        String Assistance_Request_Preferred_Timezone,
        String Artisan_Request_Creator_User_Id,
        String Artisan_Request_Creator_User_Title,
        String Artisan_Request_Creator_User_FirstName,
        String Artisan_Request_Creator_User_LastName,
        String Artisan_Request_Creator_User_Email,
        String Artisan_Request_Creator_User_Phone,
        String Artisan_Request_Creator_User_Mobile,
        String Artisan_Request_Creator_User_Street,
        String Artisan_Request_Creator_User_City,
        String Artisan_Request_Creator_User_State,
        String Artisan_Request_Creator_User_Postalcode,
        String Artisan_Request_Creator_User_Country ) {
        Id returnedCaseId = null;

        try {
            // Create the JSON request body (non-pretty) based on the parameters
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            
	    	WriteJsonField(gen, 'Customer_Org_Id', UserInfo.getOrganizationId());
	    	WriteJsonField(gen, 'Assistance_Request_Id', Assistance_Request_Id);
	    	WriteJsonField(gen, 'Assistance_Request_Name', Assistance_Request_Name);
	    	WriteJsonField(gen, 'Assistance_Request_Stage_Name', Assistance_Request_Stage_Name);
	    	WriteJsonField(gen, 'Assistance_Request_Prior_Stage_Name', Assistance_Request_Prior_Stage_Name);
	    	WriteJsonField(gen, 'Assistance_Request_Phase', Assistance_Request_Phase);
	    	WriteJsonField(gen, 'Assistance_Request_Title', Assistance_Request_Title);
	    	WriteJsonField(gen, 'Assistance_Request_Description', Assistance_Request_Description);
	    	WriteJsonField(gen, 'Assistance_Request_Success_Criteria', Assistance_Request_Success_Criteria);
	    	WriteJsonField(gen, 'Assistance_Request_Urgency', Assistance_Request_Urgency);
	    	WriteJsonField(gen, 'Assistance_Request_Date_Required', Assistance_Request_Date_Required);
	    	WriteJsonField(gen, 'Assistance_Request_Environment', Assistance_Request_Environment);
	    	WriteJsonField(gen, 'Assistance_Request_Login_Access', Assistance_Request_Login_Access);
	    	WriteJsonField(gen, 'Assistance_Request_Production_Deployment', Assistance_Request_Production_Deployment);
	    	WriteJsonField(gen, 'Assistance_Request_Sandbox_Name', Assistance_Request_Sandbox_Name);
	    	WriteJsonField(gen, 'Assistance_Request_Salesforce_Product', Assistance_Request_Salesforce_Product);
	    	WriteJsonField(gen, 'Assistance_Request_Preferred_Resource_Location', Assistance_Request_Preferred_Resource_Location);
	    	WriteJsonField(gen, 'Assistance_Request_Preferred_Billing_Currency', Assistance_Request_Preferred_Billing_Currency);
	    	WriteJsonField(gen, 'Assistance_Request_Preferred_Timezone', Assistance_Request_Preferred_Timezone);
        
	    	WriteJsonField(gen, 'Artisan_Request_Creator_User_Id', Artisan_Request_Creator_User_Id);
	    	WriteJsonField(gen, 'Artisan_Request_Creator_User_Title', Artisan_Request_Creator_User_Title);
	    	WriteJsonField(gen, 'Artisan_Request_Creator_User_FirstName', Artisan_Request_Creator_User_FirstName);
	    	WriteJsonField(gen, 'Artisan_Request_Creator_User_LastName', Artisan_Request_Creator_User_LastName);
	    	WriteJsonField(gen, 'Artisan_Request_Creator_User_Email', Artisan_Request_Creator_User_Email);
	    	WriteJsonField(gen, 'Artisan_Request_Creator_User_Phone', Artisan_Request_Creator_User_Phone);
	    	WriteJsonField(gen, 'Artisan_Request_Creator_User_Mobile', Artisan_Request_Creator_User_Mobile);
	    	WriteJsonField(gen, 'Artisan_Request_Creator_User_Street', Artisan_Request_Creator_User_Street);
 	    	WriteJsonField(gen, 'Artisan_Request_Creator_User_City', Artisan_Request_Creator_User_City);
 	    	WriteJsonField(gen, 'Artisan_Request_Creator_User_State', Artisan_Request_Creator_User_State);
	    	WriteJsonField(gen, 'Artisan_Request_Creator_User_Postalcode', Artisan_Request_Creator_User_Postalcode);
	    	WriteJsonField(gen, 'Artisan_Request_Creator_User_Country', Artisan_Request_Creator_User_Country);

            gen.writeEndObject();

            // Setup for the callout
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/');
            request.setMethod('POST');
            request.setHeader('ArtisanAssistanceAppKey', artisanAssistanceAppKey);
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Accept', 'application/json');

            // Make the request and parse the response
            request.setBody(gen.getAsString());
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
                // Unexpected response status code
                Logutils.log('The status code returned to AssistanceRequestRestResources.createRequest was unexpected [' +
                    response.getStatusCode() + ' ' + response.getStatus() + ']', 533, ArtisanRestApiCallouts.class);
                return null;
            } else {
                String jsonReturnValue = response.getBody();
             	returnedCaseId = ExtractIdFromJson(jsonReturnValue);
                String exceptionMessage = ExtractExceptionFromJson(jsonReturnValue);
                if ( exceptionMessage != null ){
                    // Exception return
                    Logutils.log('The callout to AssistanceRequestRestResources.createRequest returned an exception [' +
                        jsonReturnValue + ']', 542, ArtisanRestApiCallouts.class);
	                return null;
                }
            }    
        }  catch ( Exception e ) {
            Logutils.log(e, 'Exception in AssistanceRequestRestResources.createRequest [' + e.getMessage() + ']');
            return null;
        }
        return returnedCaseId;
    }

    // Callout to inform Artisan's production org that an Assistance Request has been updated
    // If the callout was successful returns the id of the created Case e.g. 500123123123123123 otherwise null
    // HttpPost request should be like this
    /*
	{
        "Assistance_Request_Id" : "a00123123123123",
        "Assistance_Request_Name" : "REQ1234",
        "Assistance_Request_Stage_Name" : "Waiting for Estimation",
        "Assistance_Request_Prior_Stage_Name" : "Drafting",
        "Assistance_Request_Status" : "Active",
        "Assistance_Request_Title" : "I need help",
        "Assistance_Request_Description" : "Please help me with Salesforce",
        "Assistance_Request_Success_Criteria" : "So I can solve my problem",
        "Assistance_Request_Urgency" : "High",
        "Assistance_Request_Date_Required" : "2019-07-31",
        "Assistance_Request_Environment" : "Sandbox",
        "Assistance_Request_Login_Access" : "Yes",
        "Assistance_Request_Production_Deployment" : "No",
        "Assistance_Request_Sandbox_Name" : "BAU",
        "Assistance_Request_Salesforce_Product" : "Sales Cloud",
        "Assistance_Request_Preferred_Resource_Location" : "No preference",
        "Assistance_Request_Preferred_Billing_Currency" : "AUD - Australian Dollar",
        "Assistance_Request_Preferred_Timezone" : "(GMT+10:00) Australian Eastern Standard Time (Australia/Sydney)"
	}
	*/
    //
    //  Can be tested with this anonymous Apex
    //  
    /*
    Id caseId = ArtisanRestApiCallouts.updateAssistanceRequest(
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
	system.debug('*** returned case id = ' + caseId);
	*/
    public static Id updateAssistanceRequest(
        String Assistance_Request_Id,
        String Assistance_Request_Name,
        String Assistance_Request_Stage_Name,
        String Assistance_Request_Prior_Stage_Name,
        String Assistance_Request_Phase,
        String Assistance_Request_Title,
        String Assistance_Request_Description,
        String Assistance_Request_Success_Criteria,
        String Assistance_Request_Urgency,
        String Assistance_Request_Date_Required,
        String Assistance_Request_Environment,
        String Assistance_Request_Login_Access,
        String Assistance_Request_Production_Deployment,
        String Assistance_Request_Sandbox_Name,
        String Assistance_Request_Salesforce_Product,
        String Assistance_Request_Preferred_Resource_Location,
        String Assistance_Request_Preferred_Billing_Currency,
        String Assistance_Request_Preferred_Timezone ) {
        Id returnedCaseId = null;

        try {
            // Create the JSON request body (non-pretty) based on the parameters
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            
	    	WriteJsonField(gen, 'Customer_Org_Id', UserInfo.getOrganizationId());
	    	WriteJsonField(gen, 'Assistance_Request_Id', Assistance_Request_Id);
	    	WriteJsonField(gen, 'Assistance_Request_Name', Assistance_Request_Name);
	    	WriteJsonField(gen, 'Assistance_Request_Stage_Name', Assistance_Request_Stage_Name);
	    	WriteJsonField(gen, 'Assistance_Request_Prior_Stage_Name', Assistance_Request_Prior_Stage_Name);
	    	WriteJsonField(gen, 'Assistance_Request_Phase', Assistance_Request_Phase);
	    	WriteJsonField(gen, 'Assistance_Request_Title', Assistance_Request_Title);
	    	WriteJsonField(gen, 'Assistance_Request_Description', Assistance_Request_Description);
	    	WriteJsonField(gen, 'Assistance_Request_Success_Criteria', Assistance_Request_Success_Criteria);
	    	WriteJsonField(gen, 'Assistance_Request_Urgency', Assistance_Request_Urgency);
	    	WriteJsonField(gen, 'Assistance_Request_Date_Required', Assistance_Request_Date_Required);
	    	WriteJsonField(gen, 'Assistance_Request_Environment', Assistance_Request_Environment);
	    	WriteJsonField(gen, 'Assistance_Request_Login_Access', Assistance_Request_Login_Access);
	    	WriteJsonField(gen, 'Assistance_Request_Production_Deployment', Assistance_Request_Production_Deployment);
	    	WriteJsonField(gen, 'Assistance_Request_Sandbox_Name', Assistance_Request_Sandbox_Name);
	    	WriteJsonField(gen, 'Assistance_Request_Salesforce_Product', Assistance_Request_Salesforce_Product);
	    	WriteJsonField(gen, 'Assistance_Request_Preferred_Resource_Location', Assistance_Request_Preferred_Resource_Location);
	    	WriteJsonField(gen, 'Assistance_Request_Preferred_Billing_Currency', Assistance_Request_Preferred_Billing_Currency);
	    	WriteJsonField(gen, 'Assistance_Request_Preferred_Timezone', Assistance_Request_Preferred_Timezone);

            gen.writeEndObject();

            // Setup for the callout
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/');
            request.setMethod('PUT');
            request.setHeader('ArtisanAssistanceAppKey', artisanAssistanceAppKey);
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Accept', 'application/json');

            // Make the request and parse the response
            request.setBody(gen.getAsString());
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
                // Unexpected response status code
                Logutils.log('The status code returned to AssistanceRequestRestResources.updateRequest was unexpected [' +
                    response.getStatusCode() + ' ' + response.getStatus() + ']', 666, ArtisanRestApiCallouts.class);
                return null;
            } else {
                String jsonReturnValue = response.getBody();
             	returnedCaseId = ExtractIdFromJson(jsonReturnValue);
                String exceptionMessage = ExtractExceptionFromJson(jsonReturnValue);
                if ( exceptionMessage != null ){
                    // Exception return
                    Logutils.log('The callout to AssistanceRequestRestResources.updateRequest returned an exception [' +
                        jsonReturnValue + ']', 675, ArtisanRestApiCallouts.class);
	                return null;
                }
            }    
        }  catch ( Exception e ) {
            Logutils.log(e, 'Exception in AssistanceRequestRestResources.updateRequest [' + e.getMessage() + ']');
            return null;
        }
        return returnedCaseId;
    }

    // Callout to inform Artisan's production org that a Question and Answer has been created
    // If the callout was successful returns the id of the created Question and Answer record e.g. a02123123123123123 otherwise null
    // HttpPost request should be like this
    /*
    {
            "Assistance_Request_Id" : "a00123123123123",
            "Question_Answer_Id" : "a02123123123123",
            "Question_Answer_Ref" : "CQA00000001",
            "Question" : "Why will it take 5 days to migrate this data?",
            "Asked_by_Name" : "Customer Questioner",
            "Asked_by_Email" : "customer.questioner@gmail.com",
            "Asked_by_Phone" : "+61 410 123 123"
    }
	*/
    //
    //  Can be tested with this anonymous Apex
    //  
    /*
    Id qaId = ArtisanRestApiCallouts.insertQuestionAnswer(
        'a00123123123123', // "Assistance_Request_Id"
        'a02123123123123', // "Question_Answer_Id"
        'CQA00000001', // "Question_Answer_Ref"
        'Why will it take 5 days to migrate this data?', // "Question"
        'Customer Questioner', // "Asked_by_Name"
        'customer.questioner@gmail.com', // "Asked_by_Email"
        '+61 410 123 123' ); // "Asked_by_Phone"
	system.debug('*** returned qa id = ' + qaId);
	*/
    public static String insertQuestionAnswer( // cannot return Id as the object prefix is valid in the Artisan org, not this org
        String Assistance_Request_Id,
        String Question_Answer_Id,
        String Question_Answer_Ref,
        String Question,
        String Asked_by_Name,
        String Asked_by_Email,
        String Asked_by_Phone ) 
    {
        // Set default value
        String returnedQAId = null;
        
        try {
            // Create the JSON request body (non-pretty) based on the parameters
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            
            WriteJsonField(gen, 'Assistance_Request_Id', Assistance_Request_Id);
            WriteJsonField(gen, 'Question_Answer_Id', Question_Answer_Id);
            WriteJsonField(gen, 'Question_Answer_Ref', Question_Answer_Ref);
            WriteJsonField(gen, 'Question', Question);
            WriteJsonField(gen, 'Asked_by_Name', Asked_by_Name);
            WriteJsonField(gen, 'Asked_by_Email', Asked_by_Email);
            WriteJsonField(gen, 'Asked_by_Phone', Asked_by_Phone);
            
            gen.writeEndObject();
            
            // Setup for the callout
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/');
            request.setMethod('POST');
            request.setHeader('ArtisanAssistanceAppKey', artisanAssistanceAppKey);
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Accept', 'application/json');
            
            // Make the request and parse the response
            request.setBody(gen.getAsString());
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
                // Unexpected response status code
                Logutils.log('The status code returned to QuestionsAnswersRestResources.createQuestionAndAnswer was unexpected [' +
                             response.getStatusCode() + ' ' + response.getStatus() + ']', 754, ArtisanRestApiCallouts.class);
                return null;
            } else {
                String jsonReturnValue = response.getBody();
                returnedQAId = ExtractIdFromJson(jsonReturnValue);
                String exceptionMessage = ExtractExceptionFromJson(jsonReturnValue);
                if ( exceptionMessage != null ){
                    // Exception return
                    Logutils.log('The callout to QuestionsAnswersRestResources.createQuestionAndAnswer returned an exception [' +
                                 jsonReturnValue + ']', 763, ArtisanRestApiCallouts.class);
                    return null;
                }
            }       
        }  catch ( Exception e ) {
            Logutils.log(e, 'Exception in QuestionsAnswersRestResources.createQuestionAndAnswer [' + e.getMessage() + ']');
            return null;
        }
        return returnedQAId;
    }

    // Callout to inform Artisan's production org that a Question and Answer record has been updated
    // If the callout was successful returns the id of the created Question and Answer record e.g. a02123123123123123 otherwise null
    // HttpPut request should be like this
    /*
    {
            "Artisan_Question_Answer_Id" : "a2O0p000000CFStEAO",
            "Question_Answer_Id" : "a02123123123123",
            "Question_Answer_Ref" : "AQA00000001",
			"Question_Answer_RecordType_Name" : "Customer_Question"
            "Question" : "When can I expect an estimate?",
            "Answer" : "Soon!",
            "Answered_by_Name" : "Customer Answerer",
            "Answered_by_Email" : "customer.answerer@gmail.com",
            "Answered_by_Phone" : "+61 410 123 126"
    }
	*/
    //
    //  Can be tested with this anonymous Apex
    //  
    /*
    Id qaId = ArtisanRestApiCallouts.updateQuestionAnswer(
		'a2O0p000000CFStEAO', // "Artisan_Question_Answer_Id"
        'a02123123123123', // "Question_Answer_Id"
		'AQA00000001', // "Question_Answer_Ref"
		'Customer_Question', // "Question_Answer_RecordType_Name"
		'When can I expect an estimate?', // "Question"
		'Soon!', // "Answer"
		'Customer Answerer', // "Answered_by_Name"
		'customer.answerer@gmail.com', // "Answered_by_Phone"
        '+61 410 123 126' ); // "Question"
	system.debug('*** returned qa id = ' + qaId);
	*/
    public static String updateQuestionAnswer( // cannot return Id as the object prefix is valid in the Artisan org, not this org
        String Artisan_Question_Answer_Id,
        String Question_Answer_Id,
        String Question_Answer_Ref,
        String Question_Answer_RecordType_Name,
       	String Question,
       	String Answer,
        String Answered_by_Name,
        String Answered_by_Email,
        String Answered_by_Phone ) 
    {
        // Set default value
        String returnedQAId = null;
        
        try {
            // Create the JSON request body (non-pretty) based on the parameters
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            
            WriteJsonField(gen, 'Artisan_Question_Answer_Id', Artisan_Question_Answer_Id);
            WriteJsonField(gen, 'Question_Answer_Id', Question_Answer_Id);
            WriteJsonField(gen, 'Question_Answer_Ref', Question_Answer_Ref);
            WriteJsonField(gen, 'Question_Answer_RecordType_Name', Question_Answer_RecordType_Name);
            WriteJsonField(gen, 'Question', Question);
            WriteJsonField(gen, 'Answer', Answer);
            WriteJsonField(gen, 'Answered_by_Name', Answered_by_Name);
            WriteJsonField(gen, 'Answered_by_Email', Answered_by_Email);
            WriteJsonField(gen, 'Answered_by_Phone', Answered_by_Phone);
            
            gen.writeEndObject();
            
            // Setup for the callout
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(artisanAssistanceRestApiHost + '/api/services/apexrest/QuestionAnswer/v1/');
            request.setMethod('PUT');
            request.setHeader('ArtisanAssistanceAppKey', artisanAssistanceAppKey);
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('Accept', 'application/json');
            
            // Make the request and parse the response
            request.setBody(gen.getAsString());
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
                // Unexpected response status code
                Logutils.log('The status code returned to QuestionsAnswersRestResources.updateQuestionAnswer was unexpected [' +
                             response.getStatusCode() + ' ' + response.getStatus() + ']', 850, ArtisanRestApiCallouts.class);
                return null;
            } else {
                String jsonReturnValue = response.getBody();
                returnedQAId = ExtractIdFromJson(jsonReturnValue);
                String exceptionMessage = ExtractExceptionFromJson(jsonReturnValue);
                if ( exceptionMessage != null ){
                    // Exception return
                    Logutils.log('The callout to QuestionsAnswersRestResources.updateQuestionAnswer returned an exception [' +
                                 jsonReturnValue + ']', 859, ArtisanRestApiCallouts.class);
                    return null;
                }
            }    
        }  catch ( Exception e ) {
            Logutils.log(e, 'Exception in QuestionsAnswersRestResources.updateQuestionAnswer [' + e.getMessage() + ']');
            return null;
        }
        return returnedQAId;
    }

    // Callout to poll the Artisan's production org for any updates to an active Assistance Request made since the last poll
    // If the callout was successful returns the id of the created Request e.g. a002v0000460XQ3AAM otherwise null
    // HttpPost request should be like this with the OrgId, ReqId and date passed as parameters not in the body
    /*
	https://assistdev-artisan-api.cs74.force.com/api/services/apexrest/AssistanceRequest/v1?Customer_Org_Id=00D123412341234&Assistance_Request_Id=a00123123123123&Artisan_Case_SystemModstamp=2019-05-31 12:30:05.000
    //
    //  Can be tested with this anonymous Apex
    //  
    /*
    Id RequestId = ArtisanRestApiCallouts.getRequestUpdates(
        'a00123123123123', // "Assistance_Request_Id"
        '2019-05-31 12:30:05.000'); // "Artisan_Case_SystemModstamp" can be empty string if no data has ever been received from polling
	system.debug('*** returned RequestId = ' + RequestId);
	*/
    public static Id getRequestUpdates(
        String Assistance_Request_Id,
        String Artisan_Case_SystemModstamp ) 
    {
        String returnedRequestId = null;

        try {
            // Setup the parameters
            String params = 'Assistance_Request_Id=' + Assistance_Request_Id 
                + '&Artisan_Case_SystemModstamp=' +  EncodingUtil.urlEncode( Artisan_Case_SystemModstamp, 'UTF-8');

            // Setup for the callout
            Http http = new Http();
            HttpRequest request = new HttpRequest();
			request.setEndpoint(artisanAssistanceRestApiHost + '/api/services/apexrest/AssistanceRequest/v1/?' + params);
            request.setMethod('GET');
            request.setHeader('ArtisanAssistanceAppKey', artisanAssistanceAppKey);
			request.setHeader('Content-Type', 'application/json; charset=UTF-8');
            request.setHeader('Accept', 'application/json');

            // Make the request and parse the response
//system.debug('*** About to callout to AssistanceRequestRestResources.getRequestUpdates using endpoint [' + request.getEndpoint() + '] and params [' + params + ']');
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
                // Unexpected response status code
                Logutils.log('The status code returned to AssistanceRequestRestResources.getRequestUpdates was unexpected [' +
                    response.getStatusCode() + ' ' + response.getStatus() + ']', 965, ArtisanRestApiCallouts.class);
                return null;
            } else {
                String jsonReturnValue = response.getBody();
                String exceptionMessage = ExtractExceptionFromJson(jsonReturnValue);
                if ( exceptionMessage != null ){
                    // Exception return
                    Logutils.log('The callout to AssistanceRequestRestResources.getRequestUpdates returned an exception [' +
                        jsonReturnValue + ']', 971, ArtisanRestApiCallouts.class);
	                return null;
                } else {
                    // Not an exception so parse the JSON, most common will be no updates are needed so check that first
                    if (( jsonReturnValue.length() == 4 ) && ( jsonReturnValue.compareTo('\"{}\"') == 0 )){
                        // No updates available but this is not an error
//system.debug('*** The callout to AssistanceRequestRestResources.getRequestUpdates returned no data');
                        return Assistance_Request_Id;
                    }
                    
                    // Then we have some JSON data returned as not exception and not empty JSON package
//system.debug('*** The callout to AssistanceRequestRestResources.getRequestUpdates returned [' + jsonReturnValue + ']');
                    String requestId = ProcessGetUpdatesResponse(jsonReturnValue);
//system.debug('*** ProcessGetUpdatesResponsereturned [' + requestId + ']');
                    return requestId;
                }
            }           
        }  catch ( Exception e ) {
            Logutils.log(e, 'Exception in AssistanceRequestRestResources.getRequestUpdates [' + e.getMessage() + ']');
            return null;
        } 
    }

    // Method to parse the JSON returned from a polling call to the getRequestUpdates API (only gets here if there is data to process)
    // Assistance requests always start in the customer org and hence the update passed here must pre-exist
    // Returns the request id if successful otherwise null
    // 
    // Can test with this anonymous apex if method is made public
    // 
    // String jsonReturnValue = '"{\"AssistanceRequest\":{\"attributes\":{\"type\":\"Case\",\"url\":\"/services/data/v46.0/sobjects/Case/5000p000000tXxAAAU\"},\"Id\":\"5000p000000tXxAAAU\",\"Assistance_Request_Id__c\":\"a002v000045zsZmAAI\",\"Subject\":\"this one due next sat aest high service cloud\",\"SystemModstamp\":\"2019-07-30T00:52:15.000+0000\",\"Status\":\"Waiting for Estimation\",\"Prior_Stage_Name__c\":\"Drafting\",\"Questions_Answers__r\":{\"totalSize\":2,\"done\":true,\"records\":[{\"attributes\":{\"type\":\"Question_Answer__c\",\"url\":\"/services/data/v46.0/sobjects/Question_Answer__c/a2O0p000000CGmYEAW\"},\"Case_Id__c\":\"5000p000000tXxAAAU\",\"Id\":\"a2O0p000000CGmYEAW\",\"Name\":\"AQA00000129\",\"SystemModstamp\":\"2019-07-26T05:13:03.000+0000\",\"RecordTypeId\":\"0120p0000005iYdAAI\",\"Question__c\":\"<p>my second difficult question</p>\",\"Asked_by_Name__c\":\"Richard Clarke\",\"Asked_by_Email__c\":\"richard.clarke@pscgroup.com.au\",\"Asked_by_Phone__c\":\"+61 3 8592 9000\",\"RecordType\":{\"attributes\":{\"type\":\"RecordType\",\"url\":\"/services/data/v46.0/sobjects/RecordType/0120p0000005iYdAAI\"},\"Id\":\"0120p0000005iYdAAI\",\"DeveloperName\":\"Customer_Question\"}},{\"attributes\":{\"type\":\"Question_Answer__c\",\"url\":\"/services/data/v46.0/sobjects/Question_Answer__c/a2O0p000000CHihEAG\"},\"Case_Id__c\":\"5000p000000tXxAAAU\",\"Id\":\"a2O0p000000CHihEAG\",\"Name\":\"AQA00000131\",\"SystemModstamp\":\"2019-07-30T00:52:15.000+0000\",\"RecordTypeId\":\"0120p0000005iYYAAY\",\"Question__c\":\"<p>This is my second question</p>\",\"Asked_by_Name__c\":\"Richard Clarke\",\"Asked_by_Email__c\":\"richard.clarke@pscgroup.com.au\",\"Asked_by_Phone__c\":\"+61 61410804829\",\"RecordType\":{\"attributes\":{\"type\":\"RecordType\",\"url\":\"/services/data/v46.0/sobjects/RecordType/0120p0000005iYYAAY\"},\"Id\":\"0120p0000005iYYAAY\",\"DeveloperName\":\"Artisan_Question\"}}]}}}"';
	// ArtisanRestApiCallouts.ProcessGetUpdatesResponse(jsonReturnValue);

    static private String ProcessGetUpdatesResponse( String jsonReturnValue){
        // Supported scenarios in the JSON are
        // 1 - an updated request with no questions - tested
        // 2 - an updated request with a new question - tested
        // 3 - an updated request with an updated question - tested
            
        // Check request data is creatable/updateable
        List<SObjectField> reqFieldNames = new List<SObjectField> { 
			Assistance_Request__c.Title__c, 
            Assistance_Request__c.Artisan_Case_SystemModstamp__c,
            Assistance_Request__c.Stage_Name__c,
            Assistance_Request__c.Estimated_Cost__c,
            Assistance_Request__c.Estimated_End_Date__c,
            Assistance_Request__c.Estimated_Person_Days__c,
			Assistance_Request__c.Estimated_Start_Date__c,
			Assistance_Request__c.Estimated_Cost_Commentary__c,
            Assistance_Request__c.Actual_Cost__c,
            Assistance_Request__c.Actual_End_Date__c,
            Assistance_Request__c.Actual_Person_Days__c,
            Assistance_Request__c.Actual_Start_Date__c,
            Assistance_Request__c.Actual_Cost_Commentary__c
    	};
		SecurityUtils.checkInsert( Assistance_Request__c.getSObjectType(), reqFieldNames );
		SecurityUtils.checkUpdate( Assistance_Request__c.getSObjectType(), reqFieldNames );
        
        // Check Q&A data is creatable/updateable
        List<SObjectField> qaFieldNames = new List<SObjectField> { 
            Question_Answer__c.Artisan_Question_Answer_Id__c,
            Question_Answer__c.RecordTypeId, 
            Question_Answer__c.Question__c,
            Question_Answer__c.Asked_by_Name__c,
            Question_Answer__c.Asked_by_Email__c,
            Question_Answer__c.Asked_by_Phone__c,
            Question_Answer__c.Answer__c,
            Question_Answer__c.Answered_by_Name__c,
            Question_Answer__c.Answered_by_Email__c,
            Question_Answer__c.Answered_by_Phone__c };
		SecurityUtils.checkInsert( Question_Answer__c.getSObjectType(), qaFieldNames );	
		SecurityUtils.checkUpdate( Question_Answer__c.getSObjectType(), qaFieldNames );	

        // Check create/update on Question_Answer__c.Id to work around false positive in Checkmax scanner, without this
        // the code scan report highlights FLS create and update concerns on the line below
        // 		qa.Id = mapQAData.get('Customer_Question_Answer_Id__c');
        // which makes no sense as the Id field in any record is never updateable or insertable so checking it will return
        // an exception.  Code below is in an exception handler as we expect a FLS exception to be thrown
        List<SObjectField> qaIdFieldName = new List<SObjectField> { Question_Answer__c.Id };
        try {
            SecurityUtils.checkInsert( Question_Answer__c.getSObjectType(), qaIdFieldName );	
        } catch ( Exception e ){
            // Do nothing, expected exception, cannot insert Id fields
        }
        try {
            SecurityUtils.checkUpdate( Question_Answer__c.getSObjectType(), qaIdFieldName );
        } catch ( Exception e ){
            // Do nothing, expected exception, cannot update Id fields
        }
        
        // Setup parser
        if ( jsonReturnValue.left(1) == '\"' ){
            jsonReturnValue = jsonReturnValue.mid(1, jsonReturnValue.length()-2).unescapeJava();
        }
        JSONParser parser = JSON.createParser(jsonReturnValue);

        // Setup request map ready to receive the parsed data which may be in the response
        // These fields are those in the underlying SOQL query hence they might be in the response
        // but will only be included in the JSON if they have values
        Map<String,String> mapReqData = new Map<String,String>();
        mapReqData.put('Assistance_Request_Id__c',null);
        mapReqData.put('Subject',null);
        mapReqData.put('SystemModstamp',null);
        mapReqData.put('Status',null);
        mapReqData.put('Estimated_Cost__c',null);
        mapReqData.put('Estimated_End_Date__c',null);
        mapReqData.put('Estimated_Person_Days__c',null);
        mapReqData.put('Estimated_Start_Date__c',null);
        mapReqData.put('Estimated_Cost_Commentary__c',null);
        mapReqData.put('Actual_Cost__c',null);
        mapReqData.put('Actual_End_Date__c',null);
        mapReqData.put('Actual_Person_Days__c',null);
        mapReqData.put('Actual_Start_Date__c',null);
        mapReqData.put('Actual_Cost_Commentary__c',null);
        
        // Parse data and update request after parsing (all requests start in the customer org so will need update)
        String fieldName = null;
        String fieldValue = null;
        
        List<Question_Answer__c> customerQAsForUpdate = new List<Question_Answer__c>();
        List<Question_Answer__c> artisanQAsForUpsert = new List<Question_Answer__c>();
        Map<String,String> mapQAData = new Map<String,String>();
        
        integer expectedQARecordCount = 0;
        
        while (parser.nextToken() != null) {
//system.debug('*** 1 Parsed token [' + parser.getCurrentToken() + '] with value [' + parser.getText() + ']');
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                fieldName = parser.getText();
                parser.nextToken();
                fieldValue = parser.getText();
//system.debug('*** 1 Parsed field name [' + fieldName + '] with value [' + fieldValue + ']');
                
                if ( mapReqData.containsKey(fieldName) ){
                    // This is one we want so save the value
                    mapReqData.put(fieldName,fieldValue);
// system.debug('*** Added field name [' + fieldName + '] to req map with value [' + fieldValue + ']');
                }
                
                if ( fieldName == 'Questions_Answers__r' ){
                    // Start of a Q&A block, if present will have one or more records which may or may not preexist
                    // Skip to the type field for the Question_Answer__c record
                    while (parser.nextToken() != null) {
//system.debug('*** 2 Parsed token [' + parser.getCurrentToken() + '] with value [' + parser.getText() + ']');
                        if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                            fieldName = parser.getText();
                            parser.nextToken();
                            fieldValue = parser.getText();
//system.debug('*** 2 Parsed field name [' + fieldName + '] with value [' + fieldValue + ']');
                            if (( fieldName == 'totalSize') && ( fieldValue.isNumeric() )){
                                // Capture the record count for cross checking later
                                expectedQARecordCount = integer.valueOf(fieldValue);
//system.debug('*** Will be looking for [' + expectedQARecordCount + '] QA records');
                            }
                            
                            if (( fieldName == 'type') && ( fieldValue == 'Question_Answer__c'))
                            {
// system.debug('*** Found a QA record');
                                // Start of QA record so clear map to store fields found in JSON
                                mapQAData.clear();
                                
                                mapQAData.put('Id',null);
                                mapQAData.put('Customer_Question_Answer_Id__c',null);
                                mapQAData.put('DeveloperName',null);
                                mapQAData.put('Question__c',null);
                                mapQAData.put('Asked_by_Name__c',null);
                                mapQAData.put('Asked_by_Email__c',null);
                                mapQAData.put('Asked_by_Phone__c',null);
                                mapQAData.put('Answer__c',null);
                                mapQAData.put('Answered_by_Name__c',null);
                                mapQAData.put('Answered_by_Email__c',null);
                                mapQAData.put('Answered_by_Phone__c',null);
                                
                                // Loop through collecting fields which might be in JSON up to end of the object
                                while (parser.nextToken() != null) {
//system.debug('*** 3 Parsed token [' + parser.getCurrentToken() + '] with value [' + parser.getText() + ']');
                                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME){
                                        fieldName = parser.getText();
                                        parser.nextToken();
                                        fieldValue = parser.getText();
//system.debug('*** 3 Parsed field name [' + fieldName + '] with value [' + fieldValue + ']');
                                        if ( mapQAData.containsKey(fieldName) ){
                                            if (!(( fieldName == 'Id') && ( fieldValue.left(3) == '012'))){
                                                // Capture the JSON data field ignoring the record type Id
	                                            mapQAData.put(fieldName,fieldValue);
                                            }
//system.debug('*** Added field name [' + fieldName + '] to qa map with value [' + fieldValue + ']');
                                        }
                                        
                                        // Last field in JSON block for QA is DeveloperName
                                        if (fieldName == 'DeveloperName'){
                                            // End of this Q&A record so create object ready for update/upsert
//system.debug('*** Ready to update question with mapQAData=' + mapQAData);
                                            Question_Answer__c qa = new Question_Answer__c( Assistance_Request_Id__c = mapReqData.get('Assistance_Request_Id__c'));
                                            qa.Artisan_Question_Answer_Id__c = mapQAData.get('Id');
                                            qa.Id = mapQAData.get('Customer_Question_Answer_Id__c');
                                            if ( mapQAData.get('DeveloperName') != null ){
                                                if ( mapQAData.get('DeveloperName') == Utils.customerQuestionAnswerRecordTypeAPIName ){
                                                    qa.RecordTypeId = Utils.GetCustomerQuestionAnswerRecordTypeId();
                                                } else {
                                                    qa.RecordTypeId = Utils.GetArtisanQuestionAnswerRecordTypeId();
                                                }
                                            } else {
                                                // Recordtype name is required to know how to handle the polled data
                                                throw new Utils.IntegrationException('RecordType.DeveloperName not found in polled data');
                                            }
                                            qa.Question__c = mapQAData.get('Question__c');
                                            qa.Asked_by_Name__c = mapQAData.get('Asked_by_Name__c');
                                            qa.Asked_by_Email__c = mapQAData.get('Asked_by_Email__c');
                                            qa.Asked_by_Phone__c = mapQAData.get('Asked_by_Phone__c');
                                            qa.Answer__c = mapQAData.get('Answer__c');
                                            qa.Answered_by_Name__c = mapQAData.get('Answered_by_Name__c');
                                            qa.Answered_by_Email__c = mapQAData.get('Answered_by_Email__c');
                                            qa.Answered_by_Phone__c = mapQAData.get('Answered_by_Phone__c');
                                            
                                            // Add to list depending on record type for update (customer) and upsert (artisan)
                                            if ( qa.RecordTypeId == Utils.GetCustomerQuestionAnswerRecordTypeId() ){
                                                if ( qa.Id == null ){
                                                    // Customer questions must have an Id returned in the polled data to support an update
	                                                throw new Utils.IntegrationException('Customer_Question_Answer_Id__c not found in polled data');
                                                }
                                            	customerQAsForUpdate.add(qa);
                                            } else {
                                                if ( qa.Artisan_Question_Answer_Id__c == null ){
                                                    // Artisan questions must have an Artisan_Question_Answer_Id__c returned in the polled data to support an updae
	                                                throw new Utils.IntegrationException('Id not found in polled data');
                                                }
                                            	artisanQAsForUpsert.add(qa);
                                            }
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Update existing customer questions
        if ( customerQAsForUpdate.size() > 0 ){
            // Update customer questions using the Id provided in the Artisan callback, use database.update to allow for
            // unreported failure if the customer has deleted a Q&A record to avoid re-creation as an outcome of polling
//system.debug('*** Updating customerQAsForUpdate [' + customerQAsForUpdate + ']');
            database.update( customerQAsForUpdate, false );
//system.debug('*** Updated customerQAsForUpdate [' + customerQAsForUpdate + ']');
        }

        // Upsert artisan questions
        if ( artisanQAsForUpsert.size() > 0 ){
//system.debug('*** Upserting artisanQAsForUpsert [' + artisanQAsForUpsert + ']');
            database.upsert( artisanQAsForUpsert, Question_Answer__c.Fields.Artisan_Question_Answer_Id__c, true);
//system.debug('*** Upserted artisanQAsForUpsert [' + artisanQAsForUpsert + ']');
        }
        
        // Rereive the request ready to be updated with the values extracted from JSON
        String reqId = mapReqData.get('Assistance_Request_Id__c');
        if ( reqId == null ){
        	throw new Utils.IntegrationException('Assistance_Request_Id__c not found in polled data');
        }
        
        List<Assistance_Request__c> reqForUpdate = [
            select Id, Stage_Name__c, Open_Question_Count__c
            From Assistance_Request__c
            where id = :reqId
            limit 1
            for update];
        if ( reqForUpdate.size() != 1 ){
        	throw new Utils.IntegrationException('Assistance_Request_Id__c found in polled data does not match an existing Assistance Request');
        }

        // Always update the request with these fields if values were extracted from JSON
        reqForUpdate[0].Title__c = mapReqData.get('Subject');
        reqForUpdate[0].Artisan_Case_SystemModstamp__c = DateTime.valueOfGmt(mapReqData.get('SystemModstamp').replace('T',' '));

        // If the current stage is Waiting for Clarification (open questions) then let the Q&A answering process advance it, otherwise update from the Artisan org
        // as long as the Artisan org is Waiting for Clarification pending the update
        if (( reqForUpdate[0].Open_Question_Count__c == 0 ) 
            && ( mapReqData.get('Status') != 'Waiting for Clarification' ) 
            && (reqForUpdate[0].Stage_Name__c != mapReqData.get('Status'))){
//system.debug('*** Updating Stage_Name__c from [' + reqForUpdate[0].Stage_Name__c + '] to [' + mapReqData.get('Status') + ']');
            reqForUpdate[0].Stage_Name__c = mapReqData.get('Status');
        }

        // Only clone the estimate data only if the stage is Waiting for Approval or Waiting for Acceptance
        if (( reqForUpdate[0].Stage_Name__c == 'Waiting for Approval' ) ||  ( reqForUpdate[0].Stage_Name__c == 'Waiting for Acceptance' )) {
            // M.Witchalls 18 Oct 2019 - avoid 'Argument cannot be null' errors
            String estCost = mapReqData.get('Estimated_Cost__c');
            String estEndDate = mapReqData.get('Estimated_End_Date__c');
            String estPersonDays = mapReqData.get('Estimated_Person_Days__c');
            String estStartDate = mapReqData.get('Estimated_Start_Date__c');
            if (estCost != null) reqForUpdate[0].Estimated_Cost__c = Decimal.valueOf(estCost);
            if (estEndDate != null) reqForUpdate[0].Estimated_End_Date__c = Date.valueOf(estEndDate);
            if (estPersonDays != null) reqForUpdate[0].Estimated_Person_Days__c = Decimal.valueOf(estPersonDays);
            if (estStartDate != null) reqForUpdate[0].Estimated_Start_Date__c = Date.valueOf(estStartDate);
            //reqForUpdate[0].Estimated_Cost__c = Decimal.valueOf(mapReqData.get('Estimated_Cost__c'));
            //reqForUpdate[0].Estimated_End_Date__c = Date.valueOf(mapReqData.get('Estimated_End_Date__c'));
            //reqForUpdate[0].Estimated_Person_Days__c = Decimal.valueOf(mapReqData.get('Estimated_Person_Days__c'));
            //reqForUpdate[0].Estimated_Start_Date__c = Date.valueOf(mapReqData.get('Estimated_Start_Date__c'));
            reqForUpdate[0].Estimated_Cost_Commentary__c = mapReqData.get('Estimated_Cost_Commentary__c');
        }
        
        // Only clone the actual data only if the stage is Waiting for Acceptance
        if ( reqForUpdate[0].Stage_Name__c == 'Waiting for Acceptance' ) {
            // Replicate any actual data 
            // M.Witchalls 18 Oct 2019 - avoid 'Argument cannot be null' errors
            String actCost = mapReqData.get('Actual_Cost__c');
            String actEndDate = mapReqData.get('Actual_End_Date__c');
            String actPersonDays = mapReqData.get('Actual_Person_Days__c');
            String actStartDate = mapReqData.get('Actual_Start_Date__c');
            if (actCost != null) reqForUpdate[0].Actual_Cost__c = Decimal.valueOf(actCost);
            if (actEndDate != null) reqForUpdate[0].Actual_End_Date__c = Date.valueOf(actEndDate);
            if (actPersonDays != null) reqForUpdate[0].Actual_Person_Days__c = Decimal.valueOf(actPersonDays);
            if (actStartDate != null) reqForUpdate[0].Actual_Start_Date__c = Date.valueOf(actStartDate);
            //reqForUpdate[0].Actual_Cost__c = Decimal.valueOf(mapReqData.get('Actual_Cost__c'));
            //reqForUpdate[0].Actual_End_Date__c = Date.valueOf(mapReqData.get('Actual_End_Date__c'));
            //reqForUpdate[0].Actual_Person_Days__c = Decimal.valueOf(mapReqData.get('Actual_Person_Days__c'));
            //reqForUpdate[0].Actual_Start_Date__c = Date.valueOf(mapReqData.get('Actual_Start_Date__c'));
            reqForUpdate[0].Actual_Cost_Commentary__c = mapReqData.get('Actual_Cost_Commentary__c');
        }
        
        // Update data based on JSON response after the questions as any answers provided can alter the request stage
//system.debug('*** Updating reqForUpdate [' + reqForUpdate + ']');
        update reqForUpdate;
//system.debug('*** Updated reqForUpdate [' + reqForUpdate + ']');

        return reqId;
    }
}