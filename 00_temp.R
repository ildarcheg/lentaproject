source("00_dbmongo.R")
x <- 1f0

#commandArgs <- function() c(as.Date(Sys.time())-5, as.Date(Sys.time()))
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
updateString <- paste0('{ "$set": {"status":0, "process":"", "updated_at":"', updated_at, '"} }')
GetCollection(DefCollections()[3])$update('{}', update = updateString, upsert = FALSE, multiple = TRUE)  

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


df <- problemsCollection$find()
linksCollection <- GetCollection(DefCollections()[2])

for (i in 1:nrow(df)) {
  link <- df$link[i]
  queryString <- ListToQuery(list(link = link))
  dt <- linksCollection$find(queryString)
  linkDate <- dt$linkDate[1]
  print(paste0(linkDate, " ", link))
  updateList <- list(link = link, linkDate = dt$linkDate[1])
  updateString <- ListToQuery(list('$set' = updateList))  
  print(updateString)
  problemsCollection$update(queryString, update = updateString, upsert = FALSE)
}

df <- problemsCollection$find()
linksCollection <- GetCollection(DefCollections()[2])

for (i in 1:nrow(df)) {
  link <- df$link[i]
  queryString <- ListToQuery(list(link = link))
  dt <- linksCollection$find(queryString)
  linkDate <- dt$linkDate[1]
  print(paste0(linkDate, " ", link))
  updateList <- list(link = link, linkDate = dt$linkDate[1])
  updateString <- ListToQuery(list('$set' = updateList))  
  print(updateString)
  problemsCollection$update(queryString, update = updateString, upsert = FALSE)
}





source("00_dbmongo.R")
df <- historyCollection$find()
links <- unique(df$link)
changesList <- list()
numberOfChanges <- 0
for (i in 1:length(links)) {
  dfl <- df %>% filter(link == links[i]) %>% arrange(historyTime)
  print("--------")
  print(i)
  print(nrow(dfl))
  print(links[i])
  print(links[i])
  print(dfl$historyTime)
  if (nrow(dfl) >= 2) {
    for (k in (2:nrow(dfl))) {
      x1 <- dfl$page[k-1][[1]]$plaintext[1] %>% strsplit(" ") %>% unlist(use.names = FALSE)
      x2 <- dfl$page[k][[1]]$plaintext[1] %>% strsplit(" ") %>% unlist(use.names = FALSE)
      diffBefore <- setdiff(x1, x2)
      diffAfter <- setdiff(x2, x1)
      x1stemed <- dfl$page[k-1][[1]]$stemedPlaintext[1] %>% strsplit(" ") %>% unlist(use.names = FALSE)
      x2stemed <- dfl$page[k][[1]]$stemedPlaintext[1] %>% strsplit(" ") %>% unlist(use.names = FALSE)  
      diffBeforeStemed <- setdiff(x1stemed, x2stemed)
      diffAfterStemed <- setdiff(x2stemed, x1stemed)    
      if ((length(diffBefore) > 0)|(length(diffAfter) > 0)|(length(diffBeforeStemed) > 0)|(length(diffAfterStemed) > 0)) {
        numberOfChanges <- numberOfChanges + 1
        changesList[[numberOfChanges]] <- data.frame(link = links[i], linkDate = dfl$linkDate[k], changeDate = dfl$historyTime[k], 
                                                     diffBefore = paste0(diffBefore, collapse = " "), diffAfter = paste0(diffAfter, collapse = " "),
                                                     diffBeforeStemed = paste0(diffBeforeStemed, collapse = " "), diffAfterStemed = paste0(diffAfterStemed, collapse = " "))
      }
    }
  }

  
}