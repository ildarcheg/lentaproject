source("00_dbmongo.R")


commandArgs <- function() c("1999-09-01", "1999-09-07")
source('00_add_days.R')

commandArgs <- function() c(100)
source('01_days_process.R')

commandArgs <- function() c(100)
source('02_links_process.R')

commandArgs <- function() c(100)
source('03_pages_process.R')


updated_at <- GetUpdatedAt()
updateString <- paste0('{ "$set": {"status":0, "process":"", "updated_at":"', updated_at, '"} }')
GetCollection(DefCollections()[2])$update('{}', update = updateString, upsert = FALSE, multiple = TRUE)  

updated_at <- GetUpdatedAt()
queryString <- paste0('{"status":1}')
updateString <- paste0('{ "$set": {"status":0, "process":"", "updated_at":"', updated_at, '"} }')
GetCollection(DefCollections()[2])$update(queryString, update = updateString, upsert = FALSE, multiple = TRUE)  

updated_at <- GetUpdatedAt()
queryString <- paste0('{"status":2}')
updateString <- paste0('{ "$set": {"status":0, "process":"", "updated_at":"', updated_at, '"} }')
GetCollection(DefCollections()[3])$update(queryString, update = updateString, upsert = FALSE, multiple = TRUE)  

updated_at <- GetUpdatedAt()
queryString <- paste0('{"status":1}')
updateString <- paste0('{ "$set": {"status":0, "process":"", "updated_at":"', updated_at, '"} }')
GetCollection(DefCollections()[4])$update(queryString, update = updateString, upsert = FALSE, multiple = TRUE)  

# REMOVE
GetCollection(DefCollections()[1])$remove('{}')
GetCollection(DefCollections()[2])$remove('{}')
GetCollection(DefCollections()[3])$remove('{}')
GetCollection(DefCollections()[4])$remove('{}')

daysCollection$drop()
linksCollection$drop()
pageCollection$drop()
articlesCollection$drop()


dayscollection <- mongo(collection = "dayscollection",  db = "lenta", url = "mongodb://localhost")

articlesStartDate <- as.Date("1999-09-01")
articlesEndDate <- as.Date("2017-06-30")

archivePagesLinks <- paste0(baseURL, "/", year(dayArray), 
  "/", formatC(month(dayArray), width = 2, format = "d", flag = "0"), 
  "/", formatC(day(dayArray), width = 2, format = "d", flag = "0"), 
  "/")


res <- system("./mystem -cl", intern = TRUE, input = "Васе показали два ящика белых медведей")
res <- gsub("[{}]", "", res)
res <- gsub("(\\|[^ ]+)", "", res)
res <- gsub("\\?", "", res)
res <- gsub("\\s+", " ", res)
res

#dayscollection$find('{ "$or": [ { "b": 6 }, { "c": 10 } ] }')
#dayscollection$find('{ "b": { "$in" : [ 6, 8, 10]  } }')