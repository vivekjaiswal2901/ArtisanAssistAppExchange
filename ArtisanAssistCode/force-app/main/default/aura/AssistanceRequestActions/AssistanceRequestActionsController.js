({
    // Functions to set the stage depending on which button is clicked
    setStageNameWaitingForEstimationJS : function (component, event, helper) {
        helper.setStageName(component, event, helper, 'Waiting for Estimation');
    },

    setStageNameWaitingForDevelopmentJS : function (component, event, helper) {
        helper.setStageName(component, event, helper, 'Waiting for Development');
    },

    setStageNameWaitingForDeploymentJS : function (component, event, helper) {
        helper.setStageName(component, event, helper, 'Waiting for Deployment');
    },

    setStageNameAcceptedAsCompleteJS : function (component, event, helper) {
        helper.setStageName(component, event, helper, 'Accepted As Complete');
    },

    setStageNameRejectedJS : function (component, event, helper) {
        helper.setStageName(component, event, helper, 'Rejected');
    },
    
    // Function to call Apex controller to poll the Artisan org for data changes
    pollArtisanNowJS : function (component, event, helper) {
        helper.pollArtisanNowHelper(component, event, helper);
    },
    
    // Function called when the record view is refreshed
    isRefreshed: function(component, event, helper) {
    	helper.updateButtonVisibilityServer(component, event, helper);

        // M.Witchalls Oct 2019 
        // force:refreshView currently does not work in the Edge browser - 
        // the workaround is a complete page refresh
        if (/edge/.test(navigator.userAgent.toLowerCase())) {
            location.reload();
        }      
    },
    
    // Function called when the recordData is updated NOTE does not get called as it should on edit
    recordUpdated : function(component, event, helper) {
        var changeType = event.getParams().changeType;
		if (changeType === "CHANGED") {
	    	helper.updateButtonVisibilityServer(component, event, helper);
        }
    },
    
    // Function called on component initialisation
	doInit : function(component, event, helper) {
        //helper.getNameSpacePrefix(component, event, helper);
        // M.Witchalls 18 Oct 2019
        helper.updateButtonVisibilityServer(component, event, helper);
    },    
})