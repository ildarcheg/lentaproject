print("link,linkDate,datetime,rubric,subrubric,stemedPlaintext");
db.c04_articlestobeprocessed.find({}, {link:1, linkDate:1, "page.datetime":1, "page.rubric":1, "page.subrubric":1, "page.stemedPlaintext":1}).forEach(function(obj){
  print(obj.link+","+obj.linkDate+","+obj.page[0].datetime+","+obj.page[0].rubric+","+obj.page[0].subrubric+","+obj.page[0].stemedPlaintext);
});