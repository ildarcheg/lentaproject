require(rvest)
source("dbmongo.R")

args <- commandArgs()
numberOfDaysToProcess <- as.integer(args[length(args)])
if (is.na(numberOfDaysToProcess)) {
  numberOfDaysToProcess <- 1
}

daysCollection <- GetCollection("daytobeprocessed")
linksCollection <- GetCollection("linkstobeprocessed")
baseURL <- GetDefaultValue("baseURL")

process <- paste0(runif(1, 1, 10), runif(1, 1, 10), collapse = "")
updatedat <- format(Sys.time(), "%a %b %d %X %Y %Z")

for (i in 1:numberOfDaysToProcess) {
  queryString <- paste0('{"status":0}')
  updateString <- paste0('{ "$set": {"status":1, "process":"', process, '", "updatedat":"', updatedat, '"} }')
  daysCollection$update(query = queryString, update = updateString, upsert = FALSE, multiple = FALSE)  
}

queryString <- paste0('{"process":"', process, '"}')
daysToProcess <- daysCollection$find(queryString)

for (i in 1:nrow(daysToProcess)) {
  archivePageLink <- daysToProcess$archivePageLink[i]
  archiveDay <- daysToProcess$day[i]
  
  if (is.null(archivePageLink)) next
  pg <- read_html(archivePageLink, encoding = "UTF-8")
  linksOnPage <- html_nodes(pg, 
                            xpath=".//section[@class='b-longgrid-column']//div[@class='titles']//a") %>% 
    html_attr("href") 
  
  updatedat <- format(Sys.time(), "%a %b %d %X %Y %Z")
  for (k in 1:length(linksOnPage)) {
    link <- linksOnPage[k]
    link <- paste0(baseURL, link)
    queryString <- paste0('{"link":"', link, '"}')
    updateString <- paste0('{ "$set": {"link":"', link, '", "day":"', archiveDay, '","status":0, "updatedat":"', updatedat, '", "process":""} }')
    linksCollection$update(queryString, update = updateString, upsert = TRUE)
  }
  queryString <- paste0('{"archivePageLink":"', archivePageLink, '"}')
  daysCollection$remove(queryString) 
}


