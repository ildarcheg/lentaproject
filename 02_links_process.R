require(rvest, quietly = TRUE)
require(jsonlite, quietly = TRUE)
source("00_dbmongo.R")
source("00_read_html.R")

#stopifnot(GetCPULoad() < 85)
print(paste0("START: ", format(Sys.time(), "%Y-%m-%d-%H-%M-%S %Z")))

args <- commandArgs()
print(paste0("Arguments: ", args))
numberOfLinksToProcess <- as.integer(args[length(args)])
if (is.na(numberOfLinksToProcess)) {
  numberOfLinksToProcess <- 1
}
print(paste0("After arguments: ", format(Sys.time(), "%Y-%m-%d-%H-%M-%S %Z")))

linksCollection <- GetCollection(DefCollections()[2])
print(paste0("links: ", linksCollection$count()))
pagesCollection <- GetCollection(DefCollections()[3])
print(paste0("pages: ", pagesCollection$count()))

process <- paste0(runif(1, 1, 10), runif(1, 1, 10), collapse = "")
print(paste0("process: ", process))
updated_at <- GetUpdatedAt()
print(paste0("updated_at: ", updated_at))

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
  socialDF <- ReadSocial(link, archiveDay)
  commentDF <- ReadComment(link, archiveDay)
  
  updated_at <- GetUpdatedAt()
  pageDF <- cbind(link = link, linkDate = archiveDay, status = 0, updated_at = updated_at, process = "", pageDF, socialDF, commentDF, stringsAsFactors = FALSE)
  queryString <- paste0('{"link":"', link, '"}')
  
  pageJSON <- toJSON(pageDF)
  updateString <- gsub("\\[|\\]", "", pageJSON)  

  pagesCollection$update(queryString, update = updateString, upsert = TRUE)
  updateString <- paste0('{ "$set": {"status":2, "process":"", "updated_at":"', updated_at, '"} }')
  linksCollection$update(queryString, update = updateString, upsert = TRUE)
}


