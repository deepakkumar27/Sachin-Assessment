trigger AccountTrigger on Account (before insert, after insert, before update) {
    // Switch statement to handle different trigger operation types
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            // This method sets the Active__c field of newly inserted Account records to false
            AccountTriggerHandler.saveAccountsAsInactive(Trigger.New);
        }
        when AFTER_INSERT {
            // This method creates two Team Member records for each newly inserted Account record
            AccountTriggerHandler.createAccountsWithTM(Trigger.New);
        }
        when BEFORE_UPDATE {
            // This method handles logic related to Account activation and ensures required team members are present
            AccountTriggerHandler.handleBeforeUpdateActivation(Trigger.New, Trigger.oldMap);
        }
    }
}