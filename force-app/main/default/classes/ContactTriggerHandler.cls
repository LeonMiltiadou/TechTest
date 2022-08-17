public class ContactTriggerHandler extends TriggerHandler {
    public override void afterInsert() {
        List<Case> caseList = new List <Case>();
    
        for(Contact contact : (List<Contact>) Trigger.new){
    
            Case c = new Case(ContactId=contact.id, Status='Working', Origin='New Contact', OwnerId=Contact.OwnerId);

            switch on contact.Level__c{
                when 'Primary'{
                    c.Priority = 'High';
                }
                when 'Secondary'{
                    c.Priority = 'Medium';
                }
                when 'Tertiary'{
                    c.Priority = 'Low';
                }
            }

            if(Contact.AccountId != null){
                c.AccountId = Contact.AccountId;
            }
            caseList.add(c);
        }

        //fix this 
        if (Schema.sObjectType.Contact.isUpdateable()) {
            insert caseList; 
        }
      }
}
