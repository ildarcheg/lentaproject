require(tibble)
require(dplyr)
require(tm)
require(stringr)

DefCollections <- function() {
  collections <- c("c01_daytobeprocessed", "c02_linkstobeprocessed", "c03_pagestobeprocessed", "c04_articlestobeprocessed")
  return(collections)
}

DefScripts <- function() {
  scripts <- c("01_days_process.R", "02_links_process.R", "03_pages_process.R", "04_articles_pprocess.R")
  return(scripts)
}

GetCPULoad <- function() {
  cpu <- system("sar 2 3", intern = TRUE)[7] %>% stripWhitespace %>% str_split(" ")
  cpu <- cpu[[1]][3]
  cpu <- as.numeric(cpu)
  return(cpu)
}

GetDBStatus <- function() {
  dfStatus <- tibble(coll=as.character(), total=as.integer(), 
                     status0=as.integer(), 
                     status1=as.integer(), 
                     status2=as.integer(),
                     lastUpdate=as.character(),
                     sizeMb=as.character(),
                     processes=as.integer())
  collections <- DefCollections()
  
  for (i in 1:length(collections)) {
    collection <- GetCollection(collections[i])
    df <- collection$find(fields = '{"status" : true, "updated_at" : true, "_id": false}')
    
    total <- df %>% nrow()
    status0 <- df %>% filter(status==0) %>% nrow()
    status1 <- df %>% filter(status==1) %>% nrow()
    status2 <- df %>% filter(status==2) %>% nrow()
    lastUpdate <- df %>% summarise(up=max(updated_at)) %>% unlist(use.names = FALSE)
    commandSize <- paste0("mongo lenta --eval 'db.", collections[i], ".totalSize()'")
    sizeByte <- as.integer(system(commandSize, intern = TRUE)[4])
    sizeMb <- format(structure(sizeByte, class="object_size"), units="Kb")
    processes <- length(GetCollection(collections[i])$distinct("process"))-1
    if (is.null(lastUpdate)) { lastUpdate <- "" }
    dfStatus <- add_row(dfStatus, 
                        coll=collections[i],
                        total=total,
                        status0=status0,
                        status1=status1,
                        status2=status2,
                        lastUpdate=lastUpdate,
                        sizeMb=sizeMb,
                        processes=processes)
  }
  dfStatus
}

GetPerformance <- function() {
  dfPerformance <- tibble(script=as.character(), 
                     PID=as.character(), 
                     cpu=as.integer(), 
                     memory=as.integer())  
  scripts <- DefScripts()
  for (i in 1:length(scripts)) {
    script <- scripts[i]
    command <- paste0('ps aux | grep -v grep | grep "', script, '"') 
    
    oldw <- getOption("warn")
    options(warn = -1)
    res <- system(command, intern = TRUE) 
    options(warn = oldw)
    
    if (length(res)==0) next
    res <- stripWhitespace(res)
    for (k in 1:length(res)) {
      cpuInfo <- str_split(res[k], " ") %>% unlist(use.names = FALSE)
      dfPerformance <- add_row(dfPerformance, 
                               script=script,
                               PID=cpuInfo[2],
                               cpu=as.numeric(cpuInfo[3]),
                               memory=as.numeric(cpuInfo[4]))
    }
  }
  dfPerformance  
}

