require(jsonlite)
source("00_dbmongo.R")
source("00_tidy_page_data.R")

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

pagesToProcessD <- TityData(pagesToProcess)

for (i in 1:nrow(pagesToProcessD)) {
  link <- pagesToProcessD$link[i]
  archiveDay <- pagesToProcessD$day[i]
  
  updatedat <- format(Sys.time(), "%a %b %d %X %Y %Z")
  pageJSON <- toJSON(pagesToProcessD[i, ])
  queryString <- paste0('{"link":"', link, '"}')
  updateString <- gsub("\\[|\\]", "", pageJSON)
  
  articlesCollection$update(queryString, update = updateString, upsert = TRUE)
  updateString <- paste0('{ "$set": {"status":2, "process":"", "updatedat":"', updatedat, '"} }')
  pagesCollection$update(queryString, update = updateString, upsert = TRUE)  
}

