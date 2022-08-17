@isTest
private class CaseTriggerHandlerTest {
    @isTest
    static void taskCreatedAfterCaseInsert() {
        //should i be using start and stop test?
        Case c = new Case();
        
        insert c; 

        c = [SELECT CaseNumber From Case WHERE id = :c.id].get(0);

        List<Task> taskList = [SELECT id, Status, Subject, Priority, ActivityDate FROM Task];
        System.assertEquals(1, taskList.size(), '1 task has been created when 1 case is inserted');
        
        Task task = taskList.get(0);
        System.assertEquals('Not Started', task.Status, 'task status is "Not Started"');
        System.assertEquals('Welcome call for ' + c.CaseNumber, task.Subject, 'Welcome call for {the related Case Number}');
        System.assertEquals('Normal', task.Priority, 'task priority is "Normal"');

    }

    @isTest
    static void taskCreatedAfterCaseInsertDueDateSetBasedOffCasePriority() {
        List<Case> caseList = new List<Case>();

        Case c_Priority_High = new Case(Priority='High');
        Case c_Priority_Medium = new Case(Priority='Medium');
        Case c_Priority_Low = new Case(Priority='Low');

        caseList.add(c_Priority_High);
        caseList.add(c_Priority_Medium);
        caseList.add(c_Priority_Low);

        insert caseList; 

        c_Priority_High = [SELECT id From Case WHERE id = :c_Priority_High.id].get(0);
        c_Priority_Medium = [SELECT id From Case WHERE id = :c_Priority_Medium.id].get(0);
        c_Priority_Low = [SELECT id From Case WHERE id = :c_Priority_Low.id].get(0);

        Task task_RelatedTo_c_Priority_High = [SELECT ActivityDate FROM Task WHERE WhatId = :c_Priority_High.Id].get(0);
        Task task_RelatedTo_c_Priority_Medium = [SELECT ActivityDate FROM Task WHERE WhatId = :c_Priority_Medium.Id].get(0);
        Task task_RelatedTo_c_Priority_Low = [SELECT ActivityDate FROM Task WHERE WhatId = :c_Priority_Low.Id].get(0);

        System.assertEquals(Date.today().addDays(7), task_RelatedTo_c_Priority_High.ActivityDate, 'task due date is in 1 week');
        System.assertEquals(Date.today().addDays(14), task_RelatedTo_c_Priority_Medium.ActivityDate, 'task due date is in 2 weeks');
        System.assertEquals(Date.today().addDays(21), task_RelatedTo_c_Priority_Low.ActivityDate, 'task due date is in 3 weeks');
    }

    @isTest
    static void taskOwnerIdShouldBeSameAsCaseContactIfExists() {
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

        Case testCase = new Case(ContactID = testContact.Id);
        insert testCase;

        testContact = [SELECT OwnerId FROM Contact WHERE Id = :testContact.Id].get(0);
        List<Task> taskList = [SELECT OwnerId FROM Task WHERE WhatId = :testCase.Id];

        System.assertEquals(testContact.OwnerId, taskList.get(0).OwnerId, 'Task Owner is the same as Contact Owner id Contact related to Case does exist');
    }

    @isTest
    static void taskOwnerIdShouldBeSameAsCasetIfContactDoesNotExist() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'testU', Email='user@test.com', 
            EmailEncodingKey='UTF-8', LastName='U', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='user@testforleonmiltiadou.com');

        Case c;

        System.runAs(u) {
            c = new Case();
            insert c;  
        }
        
        c = [SELECT OwnerId From Case WHERE id = :c.id].get(0);

        List<Task> taskList = [SELECT OwnerId FROM Task];

        System.assertEquals(1, taskList.size(), '1 task has been created when 1 case is inserted');
        System.assertEquals(c.OwnerId, taskList.get(0).OwnerId, 'Task Owner is the same as Case Owner if Contact related to Case does not exist');
    }

}
