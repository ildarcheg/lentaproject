require(rvest, quietly = TRUE)
require(jsonlite, quietly = TRUE)
source("00_dbmongo.R")
source("00_read_html.R")

#stopifnot(GetCPULoad() < 85)

args <- commandArgs()
numberOfLinksToProcess <- as.integer(args[length(args)])
if (is.na(numberOfLinksToProcess)) {
  numberOfLinksToProcess <- 1
}

linksCollection <- GetCollection(DefCollections()[2])
pagesCollection <- GetCollection(DefCollections()[3])

log <- readLines("my.log")
log <- c(log, Sys.time())
log <- c(log, numberOfLinksToProcess)
log <- c(log, DefCollections()[2])
log <- c(log, linksCollection$count())

writeLines(log, "my.log")

process <- paste0(runif(1, 1, 10), runif(1, 1, 10), collapse = "")
updated_at <- GetUpdatedAt()

for (i in 1:numberOfLinksToProcess) {
  queryString <- paste0('{"status":0}')
  updateString <- paste0('{ "$set": {"status":1, "process":"', process, '", "updated_at":"', updated_at, '"} }')
  linksCollection$update(query = queryString, update = updateString, upsert = FALSE, multiple = FALSE)  
}

queryString <- paste0('{"process":"', process, '"}')
linksToProcess <- linksCollection$find(queryString)

for (i in 1:nrow(linksToProcess)) {
  link <- linksToProcess$link[i]
  archiveDay <- linksToProcess$linkDate[i]
  
  if (is.null(link)) next

  if (nchar(link) < 20) {
    queryString <- paste0('{"link":"', link, '"}')  
    linksCollection$remove(queryString) 
    next
  }
  pageDF <- ReadLink(link, archiveDay)
  updated_at <- GetUpdatedAt()
  pageDF <- cbind(link = link, linkDate = archiveDay, status = 0, updated_at = updated_at, process = "", pageDF)
  pageJSON <- toJSON(pageDF)
  queryString <- paste0('{"link":"', link, '"}')
  updateString <- gsub("\\[|\\]", "", pageJSON)

  pagesCollection$update(queryString, update = updateString, upsert = TRUE)
  updateString <- paste0('{ "$set": {"status":2, "process":"", "updated_at":"', updated_at, '"} }')
  linksCollection$update(queryString, update = updateString, upsert = TRUE)
}


