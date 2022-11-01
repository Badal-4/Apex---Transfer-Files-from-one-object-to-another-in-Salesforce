//Source Object: From which we want to transfer files
list<Contact> contactList = new list<Contact>();
 
//Get all the details of Contact where status is deceased and atleast related to Account or Opportunity
contactList = [Select Id,Company__c,Opportunity__c 
                   from Contact 
                   where Status__c = 'Deceased'
                   AND (Company__c != NULL OR Opportunity__c != NULL)];
                
//Map to get contact details while iterating over attchment records 
map<Id,Contact> contactMap= new map<Id,Contact>(contactList);
 
//Set to store all contact Ids, which will be used to get all related attachments (you can use keyset of above map as well)
set<Id> contactIds = new set<Id>();
for(Contact con : contactList){
    contactIds.add(con.Id);
}
 
//Get all corresponding files of corresponsind Source Object
list<ContentDocumentLink> allCdLinks = new list<ContentDocumentLink> ();
 
allCdLinks = [select Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility 
                                from ContentDocumentLink 
                                where LinkedEntityId IN :contactIds];
 
//Final List to insert file into new destination object
list<ContentDocumentLink> allCdLinksToInsert = new list<ContentDocumentLink> ();
 
 
for(ContentDocumentLink cdl : allCdLinks){
    cdl.Id = null;
    if(contactMap.get(cdl.LinkedEntityId).Opportunity__c == null){        
        cdl.LinkedEntityId = contactMap.get(cdl.LinkedEntityId).Company__c;
    }else{
        cdl.LinkedEntityId = contactMap.get(cdl.LinkedEntityId).Opportunity__c;
    }
    allCdLinksToInsert.add(cdl);
}
 
if(!allCdLinksToInsert.isEmpty()){
    database.Insert(allCdLinksToInsert,false);
}
