/**
 * Artisan Assistance - Assistance Request Schedulable Class to look for active requests on a schedule and and trigger a poll for all which are active
 * 
 * @author Richard Clarke
 * @date 29/07/2019
 */
public class AssistanceRequestSchedulableBatch implements Database.Batchable<sObject>, Schedulable {

    public static String ArtisanAssistancePollingJobName = 'Artisan Assistance Update Polling' + (Test.isRunningTest() ? ' TEST' : '');
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, Artisan_Case_SystemModstamp__c FROM Assistance_Request__c WHERE IsActive__c = true');
    }
    
    public void execute(SchedulableContext ctx) {
        // Limit the batch size to 20 to reduce the chance of hitting callout governor limits (max 100 callouts and 120 seconds in total)
        Database.executeBatch(new AssistanceRequestSchedulableBatch(), 20);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<Id> requestIds = new Set<Id>();
        for (Assistance_Request__c req : (List<Assistance_Request__c>)scope) {
            requestIds.add(req.Id);
        }
        if ( requestIds.size() > 0 ){
			System.enqueueJob(new AssistanceRequestUpdatePolling( requestIds ));
        }
    }
  
  	public void finish(Database.BatchableContext BC) {
    }
}