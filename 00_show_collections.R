source("00_dbmongo.R")
require(tibble)
require(dplyr)

dfStatus <- tibble(coll=as.character(), total=as.integer(), 
                 status0=as.integer(), 
                 status1=as.integer(), 
                 status2=as.integer(),
                 lastUpdate=as.character())
collections <- DefCollections()

for (i in 1:length(collections)) {
  collection <- GetCollection(collections[i])
  df <- collection$find(fields = '{"status" : true, "updated_at" : true, "_id": false}')
  
  total <- df %>% nrow()
  status0 <- df %>% filter(status==0) %>% nrow()
  status1 <- df %>% filter(status==1) %>% nrow()
  status2 <- df %>% filter(status==2) %>% nrow()
  lastUpdate <- df %>% summarise(up=max(updated_at)) %>% unlist(use.names = FALSE)
  dfStatus <- add_row(dfStatus, 
          coll=collections[i],
          total=total,
          status0=status0,
          status1=status1,
          status2=status2,
          lastUpdate=lastUpdate
          )
}
dfStatus