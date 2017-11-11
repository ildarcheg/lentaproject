source("00_utils.R")
dtStatus <- GetDBStatusCLI()
cpu <- GetCPULoadFromLog()
dt <- GetPerformanceCLI()

print(paste0("---------------------"))
print(paste0("START: ", format(Sys.time(), "%Y-%m-%d-%H-%M-%S %Z")))

if (cpu > 75) {
  print(paste0("CPU: ", cpu))
  print(paste0("STATUS: DIDNT STARTED"))
  if (nrow(dt)==0) {
    print(paste0("ALREADY STARTED PROCESSES: no processes found")) 
  } else {
    print(paste0("ALREADY STARTED PROCESSES:"))
    print(as.data.frame(dt))
  }
  print(paste0("CURRENT DB STATUS:"))
  print(dtStatus)
} else {
  print(paste0("CPU: ", cpu))
  print(paste0("STATUS: DIDNT STARTED"))
  if (nrow(dt)==0) {
    print(paste0("ALREADY STARTED PROCESSES: no processes found")) 
  } else {
    print(paste0("ALREADY STARTED PROCESSES:"))
    print(as.data.frame(dt))
  }
  print(paste0("CURRENT DB STATUS:"))
  print(dtStatus)
  dtStatusToProcess <- dtStatus[dtStatus$status0!=0, ]
  collectionToExclude <- c("temp", "problems", "c04_articlestobeprocessed")
  for (i in 1:length(collectionToExclude)) {
    dtStatusToProcess <- dtStatusToProcess[dtStatusToProcess$coll!=collectionToExclude[i], ] 
  }
  dtStatusToProcess$status0 <- as.integer(dtStatusToProcess$status0)
  dtStatusToProcess <- dtStatusToProcess[order(dtStatusToProcess$status0, decreasing = TRUE), ]
  dtStatusToProcess$coll <- gsub(" ", "", dtStatusToProcess$coll)

  if (nrow(dtStatusToProcess) == 0) {
    print(paste0("SCRIPT TO RUN: nothing to run"))
  } else {
    coll <- dtStatusToProcess$coll[1]
    print(paste0("TEMP COL:"))
    print(coll)
    scriptToRun <- DefScripts()[DefCollections() == coll]
    commandToRun <- paste0("Rscript ", scriptToRun," 50 > ",sub(".R", ".log", scriptToRun))
    print(paste0("SCRIPT TO RUN: ", commandToRun))
    system(commandToRun, wait=FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE)
  }
}