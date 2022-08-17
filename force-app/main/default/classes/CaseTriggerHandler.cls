public class CaseTriggerHandler  extends TriggerHandler{
    
    public override void afterInsert() {
        List<Task> taskList = new List <Task>();
    
        Map<Id,Case> caseMap = (Map<Id,Case>) Trigger.newMap;
        //Get all contacts associates with cases;
        
        //Is there a better way of getting the associated contact then running a SOQL to update the list?
        Map<Id,Case> caseMapUpdated = new Map<Id,Case>([SELECT Id, Contact.OwnerId FROM Case WHERE id IN :caseMap.values()]);

        for(Case c : caseMap.values()){
    
            Task t = new Task(WhatId=c.Id ,Status='Not Started', Subject='Welcome call for ' + c.CaseNumber,Priority='Normal');

            //only if contact is associated with the case otherwise associate with case owner
            Contact associatedContact = caseMapUpdated.get(c.id).Contact;

            if(associatedContact != null)
            {
                t.OwnerId=associatedContact.OwnerId;
            }else
            {
                t.OwnerId=c.OwnerId;
            }

            switch on c.Priority{   
                when 'High'{
                    t.ActivityDate = Date.today().addDays(7);
                }
                when 'Medium'{
                    t.ActivityDate = Date.today().addDays(14);
                }
                when 'Low'{
                    t.ActivityDate = Date.today().addDays(21);
                }
            }

          
            taskList.add(t);
        }

        if (Schema.sObjectType.Task.isUpdateable()) {
            insert taskList; 
        }
    }
}
