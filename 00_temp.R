source("00_dbmongo.R")


#commandArgs <- function() c(as.Date(Sys.time())-365, as.Date(Sys.time())-360)
source('00_add_days.R')

commandArgs <- function() c("1999-09-01", "2010-01-01")
source('00_add_days.R')

commandArgs <- function() c("1999-09-01", "1999-09-07")
source('00_add_days.R')

commandArgs <- function() c(100)
source('01_days_process.R')

commandArgs <- function() c(10)
source('02_links_process.R')

commandArgs <- function() c(10)
source('03_pages_process.R')

updated_at <- GetUpdatedAt()
queryString <- paste0('{"status":1}')
updateString <- paste0('{ "$set": {"status":0, "process":"", "updated_at":"', updated_at, '"} }')
GetCollection(DefCollections()[1])$update(queryString, update = updateString, upsert = FALSE, multiple = TRUE)

updated_at <- GetUpdatedAt()
updateString <- paste0('{ "$set": {"status":0, "process":"", "updated_at":"', updated_at, '"} }')
GetCollection(DefCollections()[2])$update('{}', update = updateString, upsert = FALSE, multiple = TRUE)  

updated_at <- GetUpdatedAt()
queryString <- paste0('{"status":1}')
updateString <- paste0('{ "$set": {"status":0, "process":"", "updated_at":"', updated_at, '"} }')
GetCollection(DefCollections()[2])$update(queryString, update = updateString, upsert = FALSE, multiple = TRUE)  

updated_at <- GetUpdatedAt()
queryString <- paste0('{"status":1}')
updateString <- paste0('{ "$set": {"status":0, "process":"", "updated_at":"', updated_at, '"} }')
GetCollection(DefCollections()[3])$update(queryString, update = updateString, upsert = FALSE, multiple = TRUE) 

g <- GetCollection(DefCollections()[3])$find(queryString)

updated_at <- GetUpdatedAt()
queryString <- paste0('{"status":2}')
updateString <- paste0('{ "$set": {"status":0, "process":"", "updated_at":"', updated_at, '"} }')
GetCollection(DefCollections()[3])$update(queryString, update = updateString, upsert = FALSE, multiple = TRUE)  

updated_at <- GetUpdatedAt()
queryString <- paste0('{"status":1}')
updateString <- paste0('{ "$set": {"status":0, "process":"", "updated_at":"', updated_at, '"} }')
GetCollection(DefCollections()[4])$update(queryString, update = updateString, upsert = FALSE, multiple = TRUE)  

links <- GetCollection(DefCollections()[3])$find()$link
for (i in 1:length(links)) {
  link <- links[i]
  print(i)
  print(link)
  #socialDF <- ReadSocial(link, "archiveDay")
  commentDF <- ReadComment(link, "archiveDay")
  ss <- commentDF %>% toJSON() %>% as.character()
  commentDF <- fromJSON(ss)
}
pageDF <- ReadLink(link, archiveDay)


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


dfText <- system("mongo --quiet < dbquery.js", intern = TRUE)
dfNames <- c("collection", "total", "status0", "status1", "status2", "processes", "Mb")
dfList <- dfText[(which(dfText=="----------")+1):length(dfText)] %>% str_split("\t") 
df <- as.data.frame(do.call(rbind, dfList)) %>% setNames(dfNames)


for (i in 1:50) {
system("Rscript 02_links_process.R", wait=FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE)
}
