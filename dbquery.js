console.log = function() {}
use lenta;
names = db.getCollectionNames();
var len = Object.keys(names).length;
var collinfo = [];
print("----------")
for (var i = 0; i <= (len-1); i++) {
  coll = db[names[i]];
  stat = coll.stats( { scale : 1024*1024 } )
  c  = coll.count()
  c0 = coll.count( { status : 0 } )
  c1 = coll.count( { status : 1 } )
  c2 = coll.count( { status : 2 } )
  f = "" + (coll.getName() + "                             ").substring(0,25) 
    + "\t" + (c0+c1+c2) 
    + "\t" + c0 
    + "\t" + c1 
    + "\t" + c2
    + "\t" + coll.distinct("process").length
    + "\t" + stat.size;
  print(f)
}
