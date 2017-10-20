require(jsonlite)
require(dplyr)
source("dbmongo.R")

args <- commandArgs()
numberOfPagesToProcess <- as.integer(args[length(args)])
if (is.na(numberOfPagesToProcess)) {
  numberOfPagesToProcess <- 1
}

pagesCollection <- GetCollection("pagestobeprocessed")
articlesCollection <- GetCollection("articlestobeprocessed")

process <- paste0(runif(1, 1, 10), runif(1, 1, 10), collapse = "")
updatedat <- format(Sys.time(), "%a %b %d %X %Y %Z")

for (i in 1:numberOfPagesToProcess) {
  queryString <- paste0('{"status":0}')
  updateString <- paste0('{ "$set": {"status":1, "process":"', process, '", "updatedat":"', updatedat, '"} }')
  pagesCollection$update(query = queryString, update = updateString, upsert = FALSE, multiple = FALSE)  
}

queryString <- paste0('{"process":"', process, '"}')
pagesToProcess <- pagesCollection$find(queryString)





for (i in 1:nrow(pagesToProcess)) {
  link <- pagesToProcess$link[i]
  archiveDay <- pagesToProcess$day[i]
  
  pagesToProcess
  updatedat <- format(Sys.time(), "%a %b %d %X %Y %Z")
  pageDF <- cbind(link = link, day = archiveDay, status = 0, updatedat = updatedat, process = "", pageDF)
  pageJSON <- toJSON(pageDF)
  queryString <- paste0('{"link":"', link, '"}')
  updateString <- gsub("\\[|\\]", "", pageJSON)
  
  pagesCollection$update(queryString, update = updateString, upsert = TRUE)
  linksCollection$remove(queryString) 
}


