source("00_dbmongo.R")

collections <- DefCollections()
for (i in 1:length(collections)) {
  collection <- GetCollection(collections[i])
  queryString <- ListToQuery(list(status = 1))
  fieldsString <- ListToQuery(list(link = 1, updated_at = 1))
  df <- collection$find(queryString, fields = fieldsString)
  df$updated_at <- ymd_hms(df$updated_at, tz = Sys.timezone(), quiet = TRUE)
  timeTo <- Sys.time() - 60*60*1  
  df <- df %>% filter(updated_at < timeTo)
  if (nrow(df)==0) next
  for (k in 1:nrow(df)) {
    link <- df$link[k]
    updated_at <- GetUpdatedAt()
    queryString <- ListToQuery(list(link = link))
    updateList <- list(link = link, status = 0, updated_at = updated_at, process = "")
    updateString <- ListToQuery(list('$set' = updateList)) 
    collection$update(queryString, update = updateString, upsert = FALSE)   
  }
}

