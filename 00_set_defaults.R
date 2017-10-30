source("00_dbmongo.R")
source("00_set_schedules.R")

collections <- DefCollections()
for (i in 1:length(collections)) {
  collection <- GetCollection(collections[i])
  collection$index(add = "link")
  collection$index(add = "status")
  collection$index(add = "process")
  collection$index(add = "updated_at")
}

baseURL <- "https://lenta.ru"
SetDefaultValue("baseURL", baseURL)