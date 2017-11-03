source("00_dbmongo.R")
cpu <- GetCPULoadFromLog()
dt <- GetPerformance()
dtStatus <- GetDBStatus()
print(paste0("---------------------"))
print(paste0("START: ", format(Sys.time(), "%Y-%m-%d-%H-%M-%S %Z")))
if (cpu > 85) {
  print(paste0("CPU: ", cpu))
  print(paste0("STATUS: DIDNT STARTED"))
  print(paste0("ALREADY STARTED PROCESSES:"))
  print(as.data.frame(dt))
  print(paste0("CURRENT DB STATUS:"))
  print(dtStatus)
} else {
  print(paste0("CPU: ", cpu))
  print(paste0("STATUS: STARTED"))
  print(paste0("ALREADY STARTED PROCESSES:"))
  print(as.data.frame(dt))
  print(paste0("CURRENT DB STATUS:"))
  print(as.data.frame(dtStatus))
  dtStatusToProcess <- dtStatus %>% filter(coll != "c04_articlestobeprocessed") %>% filter(status0 != 0) %>% arrange(-status0)
  if (nrow(dtStatusToProcess) == 0) {
    print(paste0("SCRIPT TO RUN: NOTHING TO RUN"))  
  } else {
    coll <- dtStatusToProcess$coll[1]
    scriptToRun <- DefScripts()[DefCollections() == coll]
    commandToRun <- paste0("Rscript ", scriptToRun," 50 >> ",sub(".R", ".log", scriptToRun))
    print(paste0("SCRIPT TO RUN:"))
    print(commandToRun)
    system(commandToRun, wait=FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE)  
  }
}