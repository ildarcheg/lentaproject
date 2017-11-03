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
  cpu <- system("cat cpu.log", intern = TRUE)[9] %>% stripWhitespace %>% str_split(" ")
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
                     sizeKb=as.character(),
                     avgObjSizeKb=as.character(),
                     processes=as.integer())
  collections <- DefCollections()
  
  for (i in 1:length(collections)) {
    collection <- GetCollection(collections[i])
    df <- collection$find(fields = '{"status" : true, "updated_at" : true, "_id": false}')
    df$updated_at <- unlist(df$updated_at, use.names = FALSE)
    total <- df %>% nrow()
    status0 <- df %>% filter(status==0) %>% nrow()
    status1 <- df %>% filter(status==1) %>% nrow()
    status2 <- df %>% filter(status==2) %>% nrow()
    #lastUpdate <- df %>% as.tbl() %>% summarise(up=max(updated_at)) %>% unlist(use.names = FALSE)
    #commandSize <- paste0("mongo lenta --eval 'db.", collections[i], ".totalSize()'")
    #sizeByte <- as.integer(system(commandSize, intern = TRUE)[4])
    collInfo <- collection$info()
    sizeKb <- format(structure(collInfo$stats$size, class="object_size"), units="Kb")
    avgO <- collInfo$stats$avgObjSize
    avgO[is.null(avgO)] <- 0
    avgObjSizeKb <- format(structure(avgO, class="object_size"), units="Kb")
    processes <- length(GetCollection(collections[i])$distinct("process"))-1
    #if (is.null(lastUpdate)) { lastUpdate <- "" }
    dfStatus <- add_row(dfStatus, 
                        coll=collections[i],
                        total=total,
                        status0=status0,
                        status1=status1,
                        status2=status2,
                        lastUpdate="",
                        sizeKb=sizeKb,
                        avgObjSizeKb=avgObjSizeKb,
                        processes=processes)
  }
  dfStatus
}

GetPerformance <- function() {
  dfPerformance <- tibble(script=as.character(), 
                     PID=as.character(), 
                     cpu=as.integer(), 
                     memory=as.integer())  
  command <- paste0('ps aux') 
  oldw <- getOption("warn")
  options(warn = -1)
  result <- system(command, intern = TRUE) 
  options(warn = oldw)
  
  scripts <- DefScripts()
  for (i in 1:length(scripts)) {
    script <- scripts[i]
    res <- grep(script, result, value=TRUE)
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

ListToQuery <- function(listToConvert) {
  query <- listToConvert %>% toJSON() %>% str_replace_all("\\[(?!\\{)|(?<!\\})\\]", "")
  return(query)
}
