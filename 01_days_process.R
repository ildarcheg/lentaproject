require(rvest, quietly = TRUE)
source("00_dbmongo.R")

args <- commandArgs()
numberOfDaysToProcess <- as.integer(args[length(args)])
if (is.na(numberOfDaysToProcess)) {
  numberOfDaysToProcess <- 1
}

daysCollection <- GetCollection(DefCollections()[1])
linksCollection <- GetCollection(DefCollections()[2])
baseURL <- GetDefaultValue("baseURL")

process <- paste0(runif(1, 1, 10), runif(1, 1, 10), collapse = "")
updated_at <- GetUpdatedAt()

for (i in 1:numberOfDaysToProcess) {
  queryString <- ListToQuery(list(status = 0))
  updateList <- list(status = 1, process = process, updated_at = updated_at)
  updateString <- ListToQuery(list('$set' = updateList)) 
  
  daysCollection$update(query = queryString, update = updateString, upsert = FALSE, multiple = FALSE)  
}

queryString <- ListToQuery(list(process = process))
daysToProcess <- daysCollection$find(queryString)

for (i in 1:nrow(daysToProcess)) {
  linkArchivePage <- daysToProcess$link[i]
  archiveDay <- daysToProcess$linkDate[i]
  if (is.null(linkArchivePage)) next
  pg <- read_html(linkArchivePage, encoding = "UTF-8")
  linksOnPage <- html_nodes(pg, 
                            xpath=".//section[@class='b-longgrid-column']//div[@class='titles']//a") %>% 
    html_attr("href") 
  
  updated_at <- GetUpdatedAt()
  if (length(linksOnPage)!=0) {
    for (k in 1:length(linksOnPage)) {
      link <- linksOnPage[k]
      if (is.null(link)|is.na(link)) next
      if (nchar(link) < 20) next
      
      link <- paste0(baseURL, link)
      
      queryString <- ListToQuery(list(link = link))
      updateList <- list(link = link, linkDate = archiveDay, status = 0, updated_at = updated_at, process = "")
      updateString <- ListToQuery(list('$set' = updateList)) 
      linksCollection$update(queryString, update = updateString, upsert = TRUE)
    }
  }
  queryString <- ListToQuery(list(link = linkArchivePage))
  updateList <- list(status = 2, process = "", updated_at = updated_at)
  updateString <- ListToQuery(list('$set' = updateList)) 
  daysCollection$update(queryString, update = updateString, upsert = TRUE)
}


