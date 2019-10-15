/*
 * Artisan Assistance Utility class with useful methods used thoughout the code base.
 *
 * @author Richard Clarke (based on prior work by Mohamed Atheek)
 * @date 10/07/2017 
 */
 
public class Utils {

	// Define custom exceptions
	public class ParametersException extends Exception {}
	public class ConfigurationException extends Exception {}
	public class DataException extends Exception {}
	public class IntegrationException extends Exception {}

    // Record type API names
	public static String customerQuestionAnswerRecordTypeAPIName = 'Customer_Question';
	public static String artisanQuestionAnswerRecordTypeAPIName = 'Artisan_Question';
    
	// Get Question and Answer record type for Customer created questions
    public static Id GetCustomerQuestionAnswerRecordTypeId(){
        Id customerQuestionAnswerRecordTypeId = Schema.SObjectType.Question_Answer__c.getRecordTypeInfosByDeveloperName().get(customerQuestionAnswerRecordTypeAPIName).getRecordTypeId();
        if (String.IsBlank(customerQuestionAnswerRecordTypeId)){
            throw new ConfigurationException('Question and Answer Record Type "Customer_Question" not found');
        }
        return customerQuestionAnswerRecordTypeId;
    }
    
	// Get Question and Answer record type for Artisan created questions
    public static Id GetArtisanQuestionAnswerRecordTypeId(){
        Id artisanQuestionAnswerRecordTypeId = Schema.SObjectType.Question_Answer__c.getRecordTypeInfosByDeveloperName().get(artisanQuestionAnswerRecordTypeAPIName).getRecordTypeId();
        if (String.IsBlank(artisanQuestionAnswerRecordTypeId)){
            throw new ConfigurationException('Question and Answer Record Type "Artisan_Question" not found');
        }
        return artisanQuestionAnswerRecordTypeId;
    }
    
    // Return the namespace prefix or an empty string if there isn't one
    // Another approach is to use a SOQL query like this
	// List<ApexClass> apexClasses = [SELECT Name, NameSpacePrefix from ApexClass READONLY where Name = 'ArtisanRestApiCallouts' and NameSpacePrefix != null LIMIT 1];
	// if ( apexClasses.size() != 0 ) then is managed
        
    public static String GetNamespacePrefix() {
        String namespacePrefix = '';
        
/*
        // This approach uses a SOQL query which is less efficient for regular callouts
		List<ApexClass> apexClasses = [SELECT NameSpacePrefix from ApexClass where NameSpacePrefix = 'assist' or NameSpacePrefix = 'assistbeta' LIMIT 1];
        if ( apexClasses.size() == 1 ){
            namespacePrefix = apexClasses[0].NameSpacePrefix;
        }
*/
        // This approach looks for a class which is known to be part of the package
        try {
            	// Try and determine the namespace not of this org but of the components in Artisan Assistance
                String[] parts = String.valueOf(ArtisanRestApiCallouts.class).split('\\.', 2);
                namespacePrefix = parts.size() == 2 ? parts[0] : '';
        } catch ( Exception e ) {
			// This might not work if not managed
        }

        return namespacePrefix;
    }
    
    // Return true if Artisan Assistance is running in a managed package
    public static Boolean isManaged() {
        return (GetNamespacePrefix() == '') ? false : true;
    }
    
    // Return the my domain this org is running under
    public static String myDomainName {
        get {
            if (myDomainName == null) {
                String[] parts = URL.getSalesforceBaseUrl().getHost().split('\\.', 2);
                myDomainName = parts.size() == 2 ? parts[0] : '';
            }
            return myDomainName;
        }
        private set;
    }
	
    public static User getUser(Id userId) {
    	SecurityUtils.checkRead(User.sObjectType, 
			new List<SObjectField> {User.Id,
                					User.Title,
                					User.Name,
									User.FirstName,
									User.LastName,
									User.Email,
									User.Phone,
									User.MobilePhone,
									User.Street,
                					User.City,
                					User.State,
                					User.Postalcode,
                					User.Country
                }
		);
    	return [SELECT Id, Title, Name, FirstName, LastName, Email, Phone, MobilePhone, Street, City, State, Postalcode, Country FROM User WHERE Id = :userId];
    }
    
    public static List<Map<String, String>> getUsersSummary() {
    	List<Map<String, String>> usersSummary = new List<Map<String, String>>();
    	SecurityUtils.checkRead(User.sObjectType, 
			new List<SObjectField> {User.UserType,
									User.Country,
									User.Id,
									User.IsActive}
		);
    	for (AggregateResult summary : [SELECT UserType, Country, Count(Id) ActiveCount FROM User WHERE IsActive = true GROUP BY UserType, Country ORDER BY UserType]) {
    		Map<String, String> m = new Map<String, String>();
    		m.put('UserType', (String)summary.get('UserType'));
    		m.put('Country', (String)summary.get('Country'));
    		m.put('ActiveCount', summary.get('ActiveCount') + '');
    		usersSummary.add(m);
    	} 
    	return usersSummary;
    }
    
    public static Organization getOrganization(Id orgId) {
    	SecurityUtils.checkRead(Organization.sObjectType, 
			new List<SObjectField> {Organization.Id,
                					Organization.PrimaryContact,
									Organization.Phone,
									Organization.OrganizationType,
									Organization.Name,
									Organization.LanguageLocaleKey,
									Organization.IsSandbox,
									Organization.InstanceName,
									Organization.DefaultLocaleSidKey,
									Organization.Street,
									Organization.City,
									Organization.State,
									Organization.PostalCode,
									Organization.Country}
		);
    	return [SELECT Id, PrimaryContact, Phone, OrganizationType, Name, LanguageLocaleKey, 
    				   IsSandbox, InstanceName, DefaultLocaleSidKey, 
    				   Street, City, State, PostalCode, Country 
    			FROM Organization
    			WHERE Id = :orgId];
    }
    
    public static Messaging.SendEmailResult sendArtisanAssistanceTextEmail( String subject, String emailBody ){
        return sendTextEmail('artisan.assistance@pscgroup.com.au', // to address
                            'artisan.assistance@pscgroup.com.au', // reply to
                            'Artisan Assistance App', 
                            subject, 
                            emailBody);
    }
    
    public static Messaging.SendEmailResult sendTextEmail(String toAddress, String replyTo, String senderName, String subject, String body) {
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		mail.setToAddresses(new String[] {toAddress});
		mail.setReplyTo(replyTo);
		mail.setSenderDisplayName(senderName);
		mail.setSubject(subject);
		mail.setPlainTextBody(body);
		return Messaging.sendEmail(new Messaging.Email[] { mail })[0];
    }
    
    public static String getJSONString(Map<String, String> installContext, Map<String, String>  uninstallContext, User u, List<Map<String, String>> usersSummary, Organization o) {
    	JSONGenerator gen = JSON.createGenerator(true);
    	gen.writeStartObject();
    	    	
    	if (installContext != null) {
	    	gen.writeFieldName('InstallContext');
	    	gen.writeObject(installContext);
    	}
    	
    	if (uninstallContext != null) {
	    	gen.writeFieldName('UninstallContext');
	    	gen.writeObject(uninstallContext);
    	}
    	
        if ( u != null ){
            gen.writeFieldName('User');
            gen.writeObject(u);
        }
        
        if ( usersSummary != null ){
            gen.writeFieldName('UsersSummary');
            gen.writeObject(usersSummary);
        }
        
        if ( o != null ){
            gen.writeFieldName('Organization');
            gen.writeObject(o);
        }
        
    	gen.writeEndObject();
    	return gen.getAsString();	
    }
    
    public static String normaliseForEmail(String s) {
    	return s == null ? '' : s.replaceAll('[^a-zA-Z0-9_]', '_');//replacing all characters other than alpha numeric or _ with _
    }
}