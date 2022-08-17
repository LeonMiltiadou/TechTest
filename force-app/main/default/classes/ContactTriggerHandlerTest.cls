@isTest
private class ContactTriggerHandlerTest {
    @isTest
    static void isCaseCreatedAfterInsert() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'testU', Email='user@test.com', 
            EmailEncodingKey='UTF-8', LastName='U', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='user@testforleonmiltiadou.com');

        Contact testContact;

        System.runAs(u) {
            testContact = new Contact(LastName='Test');
            insert testContact;  
        }

        testContact = [SELECT OwnerId From Contact WHERE id = :testContact.id].get(0);

        List<Case> caseList = [SELECT id, Status, Origin, OwnerId FROM Case WHERE ContactId = :testContact.Id];
        System.assertEquals(1, caseList.size(), '1 case has been created when 1 contact is inserted');

        Case testCase = caseList.get(0);
        System.assertEquals('Working', testCase.Status, 'case status is "Working"');
        System.assertEquals('New Contact', testCase.Origin, 'case origin is "New Contact"');
        System.assertEquals(testContact.OwnerId, testCase.OwnerId, 'Case Owner is the same as Contact Owner');

    }

    @isTest
    static void caseCreatedAccoundIdIsEqualToContactAccountIfExists() {
       
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;

        Contact testContact = new Contact(LastName='Test', AccountId = testAccount.Id);
        
        insert testContact;  
        

        testContact = [SELECT OwnerId From Contact WHERE id = :testContact.id].get(0);

        List<Case> caseList = [SELECT AccountId FROM Case WHERE ContactId = :testContact.Id];
        Case testCase = caseList.get(0);
        System.assertEquals(testAccount.Id, testCase.AccountId, 'case accountId is set to the Contact Account');

    }

    @isTest
    static void caseCreatedAfterContactInsertPriorityBasedOffContactLevel() {
        List<Contact> contactList = new List<Contact>();

        Contact c_Level_Primary = new Contact(LastName='Test1', Level__c='Primary');
        Contact c_Level_Secondary = new Contact(LastName='Test2', Level__c='Secondary');
        Contact c_Level_Tertiary = new Contact(LastName='Test3', Level__c='Tertiary');

        contactList.add(c_Level_Primary);
        contactList.add(c_Level_Secondary);
        contactList.add(c_Level_Tertiary);

        insert contactList; 

        c_Level_Primary = [SELECT id From Contact WHERE id = :c_Level_Primary.id].get(0);
        c_Level_Secondary = [SELECT id From Contact WHERE id = :c_Level_Secondary.id].get(0);
        c_Level_Tertiary = [SELECT id From Contact WHERE id = :c_Level_Tertiary.id].get(0);

        Case case_RelatedTo_c_Level_Primary = [SELECT Priority FROM Case WHERE ContactId = :c_Level_Primary.Id].get(0);
        Case case_RelatedTo_c_Level_Secondary = [SELECT Priority FROM Case WHERE ContactId = :c_Level_Secondary.Id].get(0);
        Case case_RelatedTo_c_Level_Tertiary = [SELECT Priority FROM Case WHERE ContactId = :c_Level_Tertiary.Id].get(0);

        System.assertEquals('High', case_RelatedTo_c_Level_Primary.Priority, 'case priority is "High" if related contact Level__c is "Primary"');
        System.assertEquals('Medium', case_RelatedTo_c_Level_Secondary.Priority, 'case priority is "Medium" if related contact Level__c is "Secondary"');
        System.assertEquals('Low', case_RelatedTo_c_Level_Tertiary.Priority, 'case priority is "Low" if related contact Level__c is "Tertiary"');
    }
}
