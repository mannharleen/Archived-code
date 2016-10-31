trigger countContacts on Contact (after insert, before delete) {

/*
This is a very common search item from SF users, where the requirement is to update a field on Account (or parent) based 
on the existance of Contact (or child) records. i.e. if contacts do not exist, account picklist to say "NO". 

Addendum: Having a counter on account records is easier to maintain using code than a field/picklist that says Yes/No -> think rollup fields

*/
	List<contact> bc_list = new List<contact>(); 	// we will upsert this later
	List<contact> b1 = new List<contact>();			// used to store cont records that were inserted
	List<contact> b2 = new List<contact>();			// used to store cont records that were deleted
											
   
	//get number of cont objects associated with account
	Map<id,Integer> b_map = new Map<id,Integer>();
	List<account> q_temp_lst = new List<account>([select id, (select id from contacts) from account]);
	for(account q:q_temp_lst) {	
        for(contact c:q.contacts) {
        	b_map.put(c.id,q.contacts.size());
            
        }
      	
	}
    system.debug('b_map= '+ b_map);
	
	//for inserted cont
	if(trigger.isInsert) {
		b1 = [select id, account.id from contact where id IN :trigger.new];
		for(contact bc : b1) {
            system.debug('inserted= '+bc);
			system.debug('bc.quotation.bizvalidationexist = "YES"');
			bc_list.add(bc);
		}
	}
	if (trigger.isDelete) {
        //system.debug('trigger.old= '+trigger.old);
		b2 = [select id, accountid from contact where id IN :trigger.old];
        system.debug('b2= '+b2);
		for (contact b_temp : b2) {
            system.debug('b_map.get(b_temp.id)= '+b_map.get(b_temp.id));
			if(b_map.get(b_temp.id) <= 1) {
				system.debug('deleted= '+b_temp);
                system.debug('bc.account.bizvalidationexist = "NO"');
				bc_list.add(b_temp);
			}
			
		}
		
	}
	
	//upsert bc_list;
}
