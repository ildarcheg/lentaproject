require(mongolite, quietly = TRUE)
require(jsonlite, quietly = TRUE)
require(tibble, quietly = TRUE)
require(dplyr, quietly = TRUE, warn.conflicts = FALSE)
require(tm, quietly = TRUE)
require(stringr, quietly = TRUE)
require(lubridate, quietly = TRUE)

source("00_utils.R")

SaveProblemLink <- function(link, problem) {
  updated_at <- GetUpdatedAt()
  queryString <- ListToQuery(list(link = link))
  updateList <- list(link = link, updated_at = updated_at, problem = problem)
  updateString <- ListToQuery(list('$set' = updateList))  
  GetCollection("problems")$update(queryString, update = updateString, upsert = TRUE)
}

GetUpdatedAt <- function() {
  updated_at <- format(Sys.time(), "%Y%m%d%H%M%S %Z") 
}


GetCollection <- function(collectionName) {
  collection <- mongo(collection = collectionName, db = "lenta", url = "mongodb://localhost")
  return(collection)
}

GetDefaultValue <- function(key) {
  query <- paste0('{"key":"', key, '"}')
  value <- defaultsCollection$find(query, fields = '{"_id":0, "value":1}')[1, 1][[1]]
  return(value)
}

GetDefaultValues <- function() {
  value <- defaultsCollection$find()
  return(value)
}

SetDefaultValue <- function(key, value) {
  if (is.numeric(value) != TRUE) {
    value = paste0('"', value, '"')
  }
  query <- paste0('{"key":"', key, '"}')
  updateString <- paste0('{ "$set": {"key":"', key, '", "value":', value, '} }')
  defaultsCollection$update(query, update = updateString, upsert = TRUE)
}

ListToQuery <- function(listToConvert) {
  query <- listToConvert %>% toJSON() %>% str_replace_all("\\[(?!\\{)|(?<!\\})\\]", "")
  return(query)
}

defaultsCollection <- GetCollection("c00_defaults")
problemsCollection <- GetCollection("problems")
