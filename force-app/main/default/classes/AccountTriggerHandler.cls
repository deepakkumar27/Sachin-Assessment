public class AccountTriggerHandler {
    // Sets the Active__c field of the provided list of Account records to false.
    public static void saveAccountsAsInactive(List<Account> accountList) {
        try {
            // Check if the provided list is not empty
            if (!accountList.isEmpty()) {
                // Iterate through each Account record in the list
                for (Account accObj : accountList) {
                    // Set the Active__c field of the Account record to false
                    accObj.Active__c = false;
                }
            }
        } catch (Exception e) {
            // Catch any exceptions that occur during processing
            System.debug('An error occurred: ' + e.getMessage() + ' in line ' + e.getLineNumber());
        }
    }
    
    
    //Creates two Team Member records for each Account in the provided list.
    public static void createAccountsWithTM(List<Account> accountList) {
        try {
            // Check if the provided list is not empty
            if (!accountList.isEmpty()) {
                // Create a list to hold the new Team Member records
                List<SQX_Team_Members__c> teamMembersToInsert = new List<SQX_Team_Members__c>();
                
                // Iterate through each Account record in the list
                for (Account accObj : accountList) {
                    // Create two Team Member records for each Account
                    teamMembersToInsert.add(new SQX_Team_Members__c(
                        Name = 'Team Member 1',
                        Account__c = accObj.Id,
                        Member_Type__c = '',
                        Contact_Info__c = ''
                    ));
                    teamMembersToInsert.add(new SQX_Team_Members__c(
                        Name = 'Team Member 2',
                        Account__c = accObj.Id,
                        Member_Type__c = '',
                        Contact_Info__c = ''
                    ));
                }
                
                // Insert the Team Member records into the database
                Database.insert(teamMembersToInsert, false);
            }
        } catch (Exception e) {
            // Catch any exceptions that occur during processing
            System.debug('An error occurred: ' + e.getMessage() + ' in line ' + e.getLineNumber());
        }
    }
    
    
    public static void handleBeforeUpdateActivation(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {        
        try {
            for (Account acc : newAccounts) {
                // Check if the Account is being activated and if it has team members
                if (oldAccountMap.get(acc.Id).Active__c != acc.Active__c && acc.Active__c && !hasRequiredTeamMembers(acc)) {
                    acc.addError('Cannot activate Account without HR and Admin team members.');
                }
                
                // Check if the user has the required permission set
                else if (oldAccountMap.get(acc.Id).Active__c != acc.Active__c && acc.Active__c && !hasPermissionSet('Account_Admin')) {
                    acc.addError('You do not have permission to activate accounts.');
                }
            }
        } catch (Exception e) {
            // Handle exceptions
            System.debug('An error occurred: ' + e.getMessage()+' in line '+e.getLineNumber());
        }
    }
    
    // Helper method to check if the Account has team members of HR and Admin member types
    public static Boolean hasRequiredTeamMembers(Account acc) {
        Boolean hasHR = false;
        Boolean hasAdmin = false;
        
        for (SQX_Team_Members__c teamMember : [SELECT Id, Member_Type__c FROM SQX_Team_Members__c WHERE Account__c =: acc.Id]) {
            if (teamMember.Member_Type__c == 'HR') {
                hasHR = true;
            }
            if (teamMember.Member_Type__c == 'Admin') {
                hasAdmin = true;
            }
        }
        return hasHR && hasAdmin;
    }
    
    // Helper method to check if the user has the specified permission set
    public static Boolean hasPermissionSet(String permissionSetName) {
        Set<String> userPermissionSetNames = new Set<String>();
        for (PermissionSetAssignment psa : [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()]) {
            userPermissionSetNames.add(psa.PermissionSet.Name);
        }
        return userPermissionSetNames.contains(permissionSetName);
    }
}