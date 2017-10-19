source("dbmongo.R")

dayscollection <- mongo(collection = "dayscollection",  db = "lenta", url = "mongodb://localhost")

articlesStartDate <- as.Date("1999-09-01")
articlesEndDate <- as.Date("2017-06-30")

archivePagesLinks <- paste0(baseURL, "/", year(dayArray), 
  "/", formatC(month(dayArray), width = 2, format = "d", flag = "0"), 
  "/", formatC(day(dayArray), width = 2, format = "d", flag = "0"), 
  "/")

#dayscollection$find('{ "$or": [ { "b": 6 }, { "c": 10 } ] }')
#dayscollection$find('{ "b": { "$in" : [ 6, 8, 10]  } }')