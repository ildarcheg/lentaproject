require(rvest)
require(jsonlite)
source("dbmongo.R")
source("page_parsing.R")

args <- commandArgs()
numberOfLinksToProcess <- as.integer(args[length(args)])
if (is.na(numberOfLinksToProcess)) {
  numberOfLinksToProcess <- 1
}

linksCollection <- GetCollection("linkstobeprocessed")
pagesCollection <- GetCollection("pagestobeprocessed")

process <- paste0(runif(1, 1, 10), runif(1, 1, 10), collapse = "")
updatedat <- format(Sys.time(), "%a %b %d %X %Y %Z")

for (i in 1:numberOfLinksToProcess) {
  queryString <- paste0('{"status":0}')
  updateString <- paste0('{ "$set": {"status":1, "process":"', process, '", "updatedat":"', updatedat, '"} }')
  linksCollection$update(query = queryString, update = updateString, upsert = FALSE, multiple = FALSE)  
}

queryString <- paste0('{"process":"', process, '"}')
linksToProcess <- linksCollection$find(queryString)

for (i in 1:nrow(linksToProcess)) {
  link <- linksToProcess$link[i]
  archiveDay <- linksToProcess$day[i]
  
  if (is.null(link)) next

  if (nchar(link) < 20) {
    queryString <- paste0('{"link":"', link, '"}')  
    linksCollection$remove(queryString) 
    next
  }
  pageDF <- ReadLink(link, archiveDay)
  updatedat <- format(Sys.time(), "%a %b %d %X %Y %Z")
  pageDF <- cbind(link = link, day = archiveDay, status = 0, updatedat = updatedat, process = "", pageDF)
  pageJSON <- toJSON(pageDF)
  queryString <- paste0('{"link":"', link, '"}')
  updateString <- gsub("\\[|\\]", "", pageJSON)

  pagesCollection$update(queryString, update = updateString, upsert = TRUE)
  updateString <- paste0('{ "$set": {"status":2, "process":"", "updatedat":"', updatedat, '"} }')
  linksCollection$update(queryString, update = updateString, upsert = TRUE)
}


