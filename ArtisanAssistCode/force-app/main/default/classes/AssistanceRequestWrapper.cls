/**
 * Artisan Assist Assistance Request Wrapper
 * 
 * Wrapper Class combining namespace with object
 * 
 * @author Michael Witchalls
 * @date 22/10/2019
 */
 public with sharing class AssistanceRequestWrapper {
    @AuraEnabled public String nameSpace {get; set;}    
    @AuraEnabled public Assistance_Request__c request {get; set;}
}