/**
 * Artisan Assistance Request polling support
 * 
 * @author Richard Clarke
 * @date 06/08/2019
 */
public class AssistanceRequestUpdatePolling implements Queueable, Database.AllowsCallouts {
    
    // Hold the Id of the Assistance Request for which a polling check should be done - implemented in queuable rather than future so can be called from batch
    Set<Id> requestIds;

    // In constructor capture the Id for which the polling should be done when execute is called
    public AssistanceRequestUpdatePolling( Set<Id> pollingRequestIds ) {
        this.requestIds = pollingRequestIds;
    }
    
    // On execute do the callouts
    public void execute(QueueableContext context) {
        for ( Id reqId : requestIds ){
             PollArtisanOrgForUpdate( reqId );
        }
    }
    
    public static void PollArtisanOrgForUpdate( Id reqId ){
        try {
//system.debug('*** In AssistanceRequestUpdatePolling PollArtisanOrgForUpdate handling polling for Id [' + reqId + ']');
            // Retrieve the record to get the last recorded systemmodstamp
            List<Assistance_Request__c> activeRequests = [
                Select Id, Artisan_Case_SystemModstamp__c
                from Assistance_Request__c READONLY 
                where Id = :reqId limit 1];
            if ( activeRequests.size() == 0 ){
                throw new Utils.DataException('The Request needing polling Id=[' + reqId + '] cannot be found');
            } else {
                // Do the callout to the Artisan REST API and process any response data, last checked modstamp may be unknownn
                String lastPolledSystemModStamp = '';
                if ( activeRequests[0].Artisan_Case_SystemModstamp__c != null ) {
                    lastPolledSystemModStamp = activeRequests[0].Artisan_Case_SystemModstamp__c.formatGmt('yyyy-MM-dd HH:mm:ss.SSS');
                }
                if ( ArtisanRestApiCallouts.getRequestUpdates( String.valueOf(activeRequests[0].Id), lastPolledSystemModStamp ) == null ){
                    // An error occured during the update process;
	                throw new Utils.IntegrationException('The callout to poll for updates to Request Id=[' + activeRequests[0].Id + '] failed');
                }
            }
        } catch (Exception e) {
            Logutils.log(e, 'Failed during polling Artisan org for active request update id=[' + reqId + ']');
//system.debug('*** In AssistanceRequestUpdatePolling PollArtisanOrgForUpdate exception ' + e.getMessage());
            
            // Update the record to indicate the sync failed (only happens when the request exists but gets an exception back from the callout)
            List<Assistance_Request__c> polledRequest = [
                Select Id, Sync_Status__c, Sync_Details__c 
                from Assistance_Request__c 
                where Id = :reqId limit 1 FOR UPDATE];
            if ( polledRequest.size() == 1 ){
// system.debug('*** In AssistanceRequestUpdatePolling PollArtisanOrgForUpdate on exception about to update sync status to failed');
                polledRequest[0].Sync_Status__c = 'Sync failed';
                polledRequest[0].Sync_Details__c = e.getMessage().left(255);
                database.update(polledRequest[0], false);
// system.debug('*** In AssistanceRequestUpdatePolling PollArtisanOrgForUpdate on exception after updating sync status to failed');
            }                    
        }
    }

}