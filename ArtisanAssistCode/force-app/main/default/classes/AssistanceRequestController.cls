/**
 * Artisan Assist Assistance Request controller
 * 
 * Controller class for the aura components
 * 
 * @author Richard Clarke
 * @date 05/08/2019
 */
public class AssistanceRequestController {
    
    // Change the stage
    @AuraEnabled
    public static void setNewStageNameApex( String arId, String newStageName ){
//system.debug('In AssistanceRequestController.setNewStageNameApex with Id [' + arId + '] and newStageName [' + newStageName + ']');
        try {
            List<Assistance_Request__c> reqs = [SELECT Id, Stage_Name__c FROM Assistance_Request__c WHERE Id=:arId FOR UPDATE];
            if ( reqs.size() != 1 ){
                throw new Utils.IntegrationException('Unable to locate the Assistance Request [' + arId + ']');
            }
            reqs[0].Stage_Name__c = newStageName;
            UPDATE reqs[0];
        } catch (Exception e) {
            Logutils.log(e, 'Failed to set the Assistance Request stage name to [' + newStageName + ']');
        }                
    }
    
    // Poll Artisan org now
    @AuraEnabled
    public static void pollArtisanNowApex( String arId ){
//system.debug('In AssistanceRequestController.pollArtisanNowApex with Id [' + arId + ']');
        try {
            AssistanceRequestUpdatePolling.PollArtisanOrgForUpdate( arId );
        } catch (Exception e) {
            Logutils.log(e, 'Failed to poll Artisan for updates to Assistance Request Id [' + arId + '[');
        }                
    }
    
    // Return the current namespace
    @AuraEnabled
    public static String getNameSpace(){
        return Utils.GetNamespacePrefix();
    }
    
    // Return the request for assistance with the fields populated which are needed to control button visibility
    // This was implemented because the use of recordData would not reload when the record was changed either by
    // a user's edit action or by a serverside refresh from the polling API
    @AuraEnabled
    public static Assistance_Request__c getAssistanceRequest( String arId ){
        List<Assistance_Request__c> reqs = [select Id, Stage_Name__c, IsActive__c, Production_Deployment__c from Assistance_Request__c ReADONLY where Id = :arId LIMIT 1];
        return reqs[0];
    }
}