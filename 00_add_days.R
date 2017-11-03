require(lubridate, quietly = TRUE)
source("00_dbmongo.R")

args <- commandArgs()
articlesStartDate <- as.character(args[length(args)-1])
articlesEndDate <- as.character(args[length(args)])

daytobeprocessed <- GetCollection(DefCollections()[1])

dayArray <- seq(as.Date(articlesStartDate), as.Date(articlesEndDate),
                by="days")
baseURL <- GetDefaultValue("baseURL")
updated_at <- GetUpdatedAt()

for (i in 1:length(dayArray)) {
  archiveDay <- dayArray[i]
  link <- paste0(baseURL, "/", year(archiveDay), 
                            "/", formatC(month(archiveDay), width = 2, format = "d", flag = "0"), 
                            "/", formatC(day(archiveDay), width = 2, format = "d", flag = "0"), 
                            "/") 
  queryString <- ListToQuery(list(link = link))
  updateList <- list(link = link, linkDate = format(archiveDay, "%Y%m%d"), status = 0, updated_at = updated_at, process = "")
  updateString <- ListToQuery(list('$set' = updateList)) 
  daytobeprocessed$update(queryString, update = updateString, upsert = TRUE)
}