@isTest
private class ContactTriggerHandlerTest {
    @isTest
    static void isCaseCreatedAfterInsert() {
        Contact c = new Contact(LastName='Test');
        insert c; 

        List<Case> caseList = [SELECT id FROM Case WHERE ContactId = :c.Id];
        System.assertEquals(1, caseList.size(), '1 case has been created when 1 contact is inserted');
    }
}
