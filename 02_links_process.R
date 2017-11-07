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
  queryString <- ListToQuery(list(status = 0))
  updateList <- list(status = 1, process = process, updated_at = updated_at)
  updateString <- ListToQuery(list('$set' = updateList))   
  linksCollection$update(query = queryString, update = updateString, upsert = FALSE, multiple = FALSE)  
}

queryString <- ListToQuery(list(process = process))
linksToProcess <- linksCollection$find(queryString)

for (i in 1:nrow(linksToProcess)) {
  link <- linksToProcess$link[i]
  archiveDay <- linksToProcess$linkDate[i]
  
  print(paste0("link: ", link))
  print(paste0("archiveDay: ", archiveDay))
  
  if (is.null(link)) next

  if (nchar(link) < 20) {
    queryString <- ListToQuery(list(link = link))
    linksCollection$remove(queryString) 
    next
  }
  
  pageDF <- tryCatch(ReadLink(link, archiveDay), error = function(x) {data.frame()}) 
  if (nrow(pageDF)==0) {
    errorText <- paste0("'parsing: parsing error - ", link, "'")
    print(errorText)
    system(paste0("echo ", errorText, " >> error.log"), intern = FALSE)
    SaveProblemLink(link, archiveDay, errorText)
    updated_at <- GetUpdatedAt()
    queryString <- ListToQuery(list(link = link))
  } else if (is.na(pageDF$url[1])) {
    errorText <- paste0("'parssysteming: empty link - ", link, "'")
    print(errorText)
    system(paste0("echo ", errorText, " >> error.log"), intern = FALSE)
    SaveProblemLink(link, archiveDay, errorText)
    updated_at <- GetUpdatedAt()
    queryString <- ListToQuery(list(link = link))
  } else if (is.na(pageDF$plaintext[1])) {
    errorText <- paste0("'parsing: empty text - ", link, "'")
    print(errorText)
    system(paste0("echo ", errorText, " >> error.log"), intern = FALSE)
    SaveProblemLink(link, archiveDay, errorText)
    updated_at <- GetUpdatedAt()
    queryString <- ListToQuery(list(link = link))
  } else {
    socialDF <- ReadSocial(link, archiveDay)
    commentDF <- ReadComment(link, archiveDay)
    updated_at <- GetUpdatedAt()
    queryString <- ListToQuery(list(link = link))
    updateList <- list(link = link, linkDate = archiveDay, status = 0, updated_at = updated_at, process = "", page = pageDF, social = socialDF, comments = commentDF)
    updateString <- ListToQuery(list('$set' = updateList))  
    pagesCollection$update(queryString, update = updateString, upsert = TRUE)
  }
  
  updateList <- list(status = 2, process = "", updated_at = updated_at)
  updateString <- ListToQuery(list('$set' = updateList)) 
  linksCollection$update(queryString, update = updateString, upsert = TRUE)
}


