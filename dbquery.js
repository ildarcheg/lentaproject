console.log = function() {}
use lenta;
names = db.getCollectionNames();
var len = Object.keys(names).length;
var collinfo = [];
print("----------")
for (var i = 0; i <= (len-1); i++) {
  coll = db[names[i]];
  stat = coll.stats( { scale : 1024*1024 } )
  f = "" + (coll.getName() + "                             ").substring(0,25) 
    + "\t" + coll.count() 
    + "\t" + coll.count( { status : 0 } ) 
    + "\t" + coll.count( { status : 1 } ) 
    + "\t" + coll.count( { status : 2 } )
    + "\t" + coll.distinct("process").length
    + "\t" + stat.size;
  print(f)
}
