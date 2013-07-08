function removeAll() {
    var names = db.getCollectionNames();
    for(var i = 0; i < names.length; i++) {
		if(names[i] == "system.indexes") continue;
		
		db[names[i]].dropIndexes();
	    //db[names[i]].remove({});
	    db[names[i]].drop();
    }
}
removeAll();
