public class CaseTriggerHandler  extends TriggerHandler{
    
    public override void afterInsert() {
        List<Task> taskList = new List <Task>();
    
        for(Case c : (List<Case>) Trigger.new){
    
            Task t = new Task(WhatId=c.Id ,Status='Not Started', Subject='Welcome call for ' + c.CaseNumber,Priority='Normal');

            //only if contact is associated with the case otherwise associate with case owner
            Id Contact = c.Contact.OwnerId;

            if(c.Contact != null)
            {
                t.OwnerId=c.Contact.OwnerId;
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

        //fix this 
        if (Schema.sObjectType.Task.isUpdateable()) {
            insert taskList; 
        }
      }
}
