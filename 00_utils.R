require(tibble, quietly = TRUE)
require(dplyr, quietly = TRUE, warn.conflicts = FALSE)
require(tm, quietly = TRUE)
require(stringr, quietly = TRUE)

DefCollections <- function() {
  collections <- c("c01_daytobeprocessed", 
                   "c02_linkstobeprocessed", 
                   "c03_pagestobeprocessed", 
                   "c04_articlestobeprocessed")
  return(collections)
}

DefScripts <- function() {
  scripts <- c("01_days_process.R", 
               "02_links_process.R", 
               "03_pages_process.R", 
               "04_articles_process.R")
  return(scripts)
}

GetCPULoad <- function() {
  cpu <- system("sar 1 5", intern = TRUE)[9] %>% stripWhitespace %>% str_split(" ")
  cpu <- cpu[[1]][3]
  cpu <- as.numeric(cpu)
  return(cpu)
}

GetCPULoadFromLog <- function() {
  cpu <- system("cat cpu_performance.log", intern = TRUE)[9] %>% stripWhitespace %>% str_split(" ")
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

toJsonString <- function(dt) {
  if (nrow(dt) !=1) {
    return('{}')
  } else {
    values <- c()
    columns <- names(dt)
    for (i in 1:length(columns)) {
      columnName <- columns[i]
      value <- dt[1, columnName]
      if (!is.integer(value)&&!is.numeric(value)) { value <- paste0('"', value,'"') }
      values <- c(values, paste0('"', columnName,'":',value))  
    }
  } 
  values <- paste0(values, collapse = ",")
  values <- paste0("{", values, "}")
  return(values)
}

DFToString <- function(df) {
  if (nrow(df) == 0) {
    return("")
  }
  
  rows <- c(paste0(names(df), collapse = "-tab0tab-"))
  for (i in 1:nrow(df)) {
    rowText <- c()
    for (k in 1:length(names(df))) {
      rowText <- c(rowText, as.character(df[i,k])) 
    }
    rowText <- paste0(rowText, collapse = "-tab0tab-")
    rows <- c(rows, rowText)
  }
  stringFromDF <- paste0(rows, collapse = "-tab7tab-")  
  return(stringFromDF)
}

StringToDF <- function(string) {
  if (string == "") {
    return(data.frame())
  }
  rows <- str_split(string, "-tab7tab-", simplify = TRUE)
  dfNames <- str_split(rows[1], "-tab0tab-", simplify = TRUE)
  df <- setNames(data.frame(str_split(rows[2:length(rows)], "-tab0tab-", simplify = TRUE)), dfNames)
  return(df)
}