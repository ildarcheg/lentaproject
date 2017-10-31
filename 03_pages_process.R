require(jsonlite, quietly = TRUE)
source("00_dbmongo.R")
source("00_tidy_page_data.R")

#stopifnot(GetCPULoad() < 85)

args <- commandArgs()
numberOfPagesToProcess <- as.integer(args[length(args)])
if (is.na(numberOfPagesToProcess)) {
  numberOfPagesToProcess <- 1
}

pagesCollection <- GetCollection(DefCollections()[3])
articlesCollection <- GetCollection(DefCollections()[4])

process <- paste0(runif(1, 1, 10), runif(1, 1, 10), collapse = "")
updated_at <- GetUpdatedAt()

for (i in 1:numberOfPagesToProcess) {
  queryString <- paste0('{"status":0}')
  updateString <- paste0('{ "$set": {"status":1, "process":"', process, '", "updated_at":"', updated_at, '"} }')
  pagesCollection$update(query = queryString, update = updateString, upsert = FALSE, multiple = FALSE)  
}

queryString <- paste0('{"process":"', process, '"}')
pagesToProcess <- pagesCollection$find(queryString)

pagesToProcessD <- TityData(pagesToProcess)

for (i in 1:nrow(pagesToProcessD)) {
  link <- pagesToProcessD$link[i]
  archiveDay <- pagesToProcessD$linkDate[i]
  
  updated_at <- GetUpdatedAt()
  pagesToProcessD[i, ]$status <- 0
  queryString <- paste0('{"link":"', link, '"}')
  pageJSON <- toJSON(pagesToProcessD[i, ])
  updateString <- gsub("\\[|\\]", "", pageJSON)  
  articlesCollection$update(queryString, update = updateString, upsert = TRUE)
  
  updateString <- paste0('{ "$set": {"status":2, "process":"", "updated_at":"', updated_at, '"} }')
  pagesCollection$update(queryString, update = updateString, upsert = TRUE)  
}

