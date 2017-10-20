require(lubridate)
source("dbmongo.R")

args <- commandArgs()
articlesStartDate <- as.character(args[length(args)-1])
articlesEndDate <- as.character(args[length(args)])

daytobeprocessed <- GetCollection("daytobeprocessed")

dayArray <- seq(as.Date(articlesStartDate), as.Date(articlesEndDate),
                by="days")
baseURL <- GetDefaultValue("baseURL")
updatedat <- format(Sys.time(), "%a %b %d %X %Y %Z")

for (i in 1:length(dayArray)) {
  archiveDay <- dayArray[i]
  archivePageLink <- paste0(baseURL, "/", year(archiveDay), 
                            "/", formatC(month(archiveDay), width = 2, format = "d", flag = "0"), 
                            "/", formatC(day(archiveDay), width = 2, format = "d", flag = "0"), 
                            "/") 
  queryString <- paste0('{"archivePageLink":"', archivePageLink, '"}')
  updateString <- paste0('{ "$set": {"archivePageLink":"', archivePageLink, '", "day":"', format(archiveDay, "%Y%m%d"), '", "status":0, "updatedat":"', updatedat, '", "process":""} }')
  daytobeprocessed$update(queryString, update = updateString, upsert = TRUE)
}