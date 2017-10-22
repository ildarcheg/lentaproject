source("dbmongo.R")


commandArgs <- function() c("1999-09-01", "1999-09-07")
source('add_days_to_be_processed.R')

commandArgs <- function() c(100)
source('day_process.R')
commandArgs <- function() c(100)
source('link_process.R')
commandArgs <- function() c(100)
source('page_process.R')

daysCollection <- GetCollection("daytobeprocessed")
linksCollection <- GetCollection("linkstobeprocessed")
pageCollection <- GetCollection("pagestobeprocessed")
articlesCollection <- GetCollection("articlestobeprocessed")

daysCollection$find()
linksCollection$find()
pageCollection$find()
articlesCollection$find()

updatedat <- format(Sys.time(), "%a %b %d %X %Y %Z")
updateString <- paste0('{ "$set": {"status":0, "process":"", "updatedat":"', updatedat, '"} }')
pagesCollection$update('{}', update = updateString, upsert = FALSE, multiple = TRUE)  

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