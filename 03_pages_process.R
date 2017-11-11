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
  queryString <- ListToQuery(list(status = 0))
  updateList <- list(status = 1, process = process, updated_at = updated_at)
  updateString <- ListToQuery(list('$set' = updateList))     
  pagesCollection$update(query = queryString, update = updateString, upsert = FALSE, multiple = FALSE)  
}

queryString <- ListToQuery(list(process = process))
pagesToProcessD <- pagesCollection$find(queryString)

print(paste0("Rows to process: ", nrow(pagesToProcessD)))

for (i in 1:nrow(pagesToProcessD)) {
  
  link <- pagesToProcessD$link[i]
  
  if (is.null(link)) next
  
  archiveDay <- pagesToProcessD$linkDate[i]
  
  print(paste0("link: ", link))
  print(paste0("archiveDay: ", archiveDay))
  
  pageDF <- pagesToProcessD$page[i][[1]]
  pageDF$dateToUse <- archiveDay 
  pageDF <- TityData(pageDF)
  
  socialDF <- pagesToProcessD$social[i][[1]]
  
  commentDF <- pagesToProcessD$comments[i][[1]]
  if (!is.null(commentDF)) {
    if (!is.na(commentDF)) { commentDF <- TityDataComments(commentDF) }
  } else {
    commentDF <- NA
  }
  updated_at <- GetUpdatedAt()
  queryString <- ListToQuery(list(link = link))
  updateList <- list(link = link, linkDate = archiveDay, status = 0, updated_at = updated_at, process = "", page = pageDF, social = socialDF, comments = commentDF)
  updateString <- ListToQuery(list('$set' = updateList))  
  
  articlesCollection$update(queryString, update = updateString, upsert = TRUE)
  
  # isLastWeek <- (ymd(archiveDay) >= (as.Date(Sys.time()) - 3))
  # if (isLastWeek == TRUE) {
  #   queryStringLastWeek <- ListToQuery(list(link = link, historyTime = updated_at))
  #   updateListLastWeek <- list(link = link, linkDate = archiveDay, historyTime = updated_at, updated_at = updated_at, process = "", page = pageDF, social = socialDF, comments = commentDF)
  #   updateStringLastWeek <- ListToQuery(list('$set' = updateListLastWeek))      
  #   historyCollection$update(queryStringLastWeek, update = updateStringLastWeek, upsert = TRUE)  
  # }
  
  updateList <- list(status = 2, process = "", updated_at = updated_at)
  updateString <- ListToQuery(list('$set' = updateList)) 
  pagesCollection$update(queryString, update = updateString, upsert = TRUE)  
}

