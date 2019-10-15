({
    // Set the request stage based on the button which was clicked
	setStageName : function(component, event, helper, newStage) {
        var rid = component.get("v.recordId");
        var action = component.get("c.setNewStageNameApex");
        action.setParams({arId : rid,
                          newStageName: newStage});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } 
                else {
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    // Trigger an immediate callout to Artisan to get any updated data
	pollArtisanNowHelper : function(component, event, helper) {
        var rid = component.get("v.recordId");
        var action = component.get("c.pollArtisanNowApex");
        action.setParams({arId : rid});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } 
                else {
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    // Set button visibility based on the local recordData
	updateButtonVisibilityLocal : function(component, event, helper) {
        // Get data from recordData which does not reload properly on server side edit
        var nameSpace = component.get("v.nameSpace");
        var stageName = component.get("v.simpleRequestRecord." + nameSpace + "Stage_Name__c");
        var isActive = component.get("v.simpleRequestRecord." + nameSpace + "IsActive__c");
        var prodDeploy = component.get("v.simpleRequestRecord." + nameSpace + "Production_Deployment__c");
        
        // When record is loaded set attributes controlling which buttons to display
        component.set("v.showRefreshNow",( isActive ));
        component.set("v.showRequestEstimate",( stageName == "Drafting" ));
        component.set("v.showApproveEstimate",( stageName == "Waiting for Approval" ));
        component.set("v.showApproveDeployment",(( stageName == "Being Tested" ) 
                                                 && ( prodDeploy == "Yes" )));
        component.set("v.showAcceptAsComplete",(( stageName == "Waiting for Acceptance" )
                                                || ( stageName == "Being Tested" ) 
                                                && ( prodDeploy != "Yes" )));
	},
    
    // Set button visibility based on the current request data
	updateButtonVisibilityServer : function(component, event, helper ) {
        var rid = component.get("v.recordId");
        var action = component.get("c.getAssistanceRequest");
        action.setParams({arId : rid});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Pulled the request data directly from the server to avoid caching issues
                var retVal = response.getReturnValue();
				component.set("v.simpleRequestRecord", retVal);
                
                var nameSpace = component.get("v.nameSpace");
                var stageName = component.get("v.simpleRequestRecord." + nameSpace + "Stage_Name__c");
                var isActive = component.get("v.simpleRequestRecord." + nameSpace + "IsActive__c");
                var prodDeploy = component.get("v.simpleRequestRecord." + nameSpace + "Production_Deployment__c");

                // When record is loaded set attributes controlling which buttons to display
                component.set("v.showRefreshNow",( isActive ));
                component.set("v.showRequestEstimate",( stageName == "Drafting" ));
                component.set("v.showApproveEstimate",( stageName == "Waiting for Approval" ));
                component.set("v.showApproveDeployment",(( stageName == "Being Tested" ) 
                                                         && ( prodDeploy == "Yes" )));
                component.set("v.showAcceptAsComplete",(( stageName == "Waiting for Acceptance" )
                                                        || ( stageName == "Being Tested" ) 
                                                        && ( prodDeploy != "Yes" )));
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } 
                else {
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
	},

    // Set the nameSpacePrefix attribute to an empty string or something like assist__
    getNameSpacePrefix : function(component, event, helper) {
        var action = component.get("c.getNameSpace");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var nmSpacePrefix = response.getReturnValue();
                if ( nmSpacePrefix != "" ){
                    nmSpacePrefix = nmSpacePrefix + "__";
                }
                var fieldList = nmSpacePrefix + "Stage_Name__c," + nmSpacePrefix + "Production_Deployment__c," + nmSpacePrefix + "IsActive__c";
                component.set('v.requestFieldList', fieldList);
                component.set('v.nameSpace', nmSpacePrefix);

                // Set initial button visibility after component init from the loaded recordData
				helper.updateButtonVisibilityLocal(component, event, helper);
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } 
                else {
                    console.log("Unknown Error");
                }
            }
        });
        $A.enqueueAction(action);
    }    
})