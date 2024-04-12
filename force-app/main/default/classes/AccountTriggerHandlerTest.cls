@isTest
public class AccountTriggerHandlerTest {
    // Test setup method to create test data
    @testSetup
    static void setup() {
        // Create test Account records
        List<Account> testAccounts = new List<Account>();
        for(Integer i = 0; i < 3; i++) {
            testAccounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert testAccounts;           
    }
    
    // Test method to verify saveAccountsAsInactive method
    @isTest
    static void testSaveAccountsAsInactive() {
        // Retrieve test accounts
        List<Account> testAccounts = [SELECT Id, Active__c FROM Account];
        
        // Verify that the Active__c field is set to false for all test accounts
        for(Account acc : testAccounts) {
            System.assertEquals(false, acc.Active__c, 'Active__c field should be false');
        }
    }
    
    // Test method to verify createAccountsWithTM method
    @isTest
    static void testCreateAccountsWithTM() {
        // Retrieve test accounts
        List<Account> testAccounts = [SELECT Id, Active__c FROM Account];
        
        // Verify that two Team Member records are created for each test account
        List<SQX_Team_Members__c> createdTeamMembers = [SELECT Id, Account__c FROM SQX_Team_Members__c WHERE Account__c IN :testAccounts];
        System.assertEquals(testAccounts.size() * 2, createdTeamMembers.size(), 'Correct number of Team Member records created');
    }
    
    // Test method to verify handleBeforeUpdateActivation method
    @isTest
    static void testHandleBeforeUpdateActivation() {
        // Retrieve test accounts
        List<Account> testAccounts = [SELECT Id, Active__c FROM Account LIMIT 1];
        
        // Retrieve created TeamMembers
        List<SQX_Team_Members__c> createdTeamMembers = [SELECT Id, Account__c FROM SQX_Team_Members__c WHERE Account__c IN :testAccounts];
        
        // Call the handleBeforeUpdateActivation method with modified accounts
        for(Account acc : testAccounts) {
            acc.Active__c = true; // Set accounts to active
        }
        for(Integer i = 0; i < 2; i++) {
            createdTeamMembers[i].Member_Type__c = (i == 0) ? 'HR' : 'Admin';
        }
        Test.startTest();
        update createdTeamMembers;
        update testAccounts;
        Test.stopTest();
        
        // Verify that the Active__c field remains true for accounts with HR and Admin team members
        for(Account acc : testAccounts) {
            if(AccountTriggerHandler.hasRequiredTeamMembers(acc)) {
                System.assertEquals(true, acc.Active__c, 'Active__c field should remain true');
            }
        }
    }
}