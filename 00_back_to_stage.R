source("00_dbmongo.R")

# getting objects that stays with status = 1 more than 1 hour
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

# removing the links that cannot be concidered as news articles
linkToRemove <- c("https://lenta.ru/onlin", 
                  "https://lenta.ru/video", 
                  "https://lenta.ru/photo", 
                  "https://lenta.ru/extli", 
                  "https://lenta.ru/chron",
                  "https://lenta.ru/conf/",
                  "https://lenta.ru/featu")
df <- problemsCollection$find()
df <- df %>% mutate(linkF = substr(link, 1, 22)) %>% filter((linkF %in% linkToRemove))

# putting problems links to collection for further analyses 
if (nrow(df)!=0) {
  for (i in 1:nrow(df)) {
    link <- df$link[i]
    queryString <- ListToQuery(list(link = link))
    problemsCollection$remove(queryString)
  }
}

# placing new articles links back to collection for further processing 
MoveErrosToStage <- function(variables) {
  updated_at <- GetUpdatedAt()
  linksCollection <- GetCollection(DefCollections()[2])
  df <- problemsCollection$find()
  if (nrow(df)!=0) {
    for (i in 1:nrow(df)) {
      link <- df$link[i]
      archiveDay <- df$linkDate[i]
      queryString <- ListToQuery(list(link = link))
      updateList <- list(link = link, linkDate = archiveDay, status = 0, updated_at = updated_at, process = "")
      updateString <- ListToQuery(list('$set' = updateList)) 
      linksCollection$update(queryString, update = updateString, upsert = TRUE)   
      problemsCollection$remove(queryString)
    }
  }
}
