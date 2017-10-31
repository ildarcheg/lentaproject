source("00_dbmongo.R")
print(paste0("START: ", format(Sys.time(), "%Y-%m-%d-%H-%M-%S %Z")))
cpu <- GetCPULoad()
print(paste0("CPU: ", cpu))
stopifnot(cpu<85)
print(paste0("In process:"))
dt <- GetPerformance()
print(as.data.frame(dt))
dtStatus <- GetDBStatus() %>% filter(coll != "c04_articlestobeprocessed") %>% filter(status0 != 0) %>% arrange(status1, -status0)
print(as.data.frame(dtStatus))
stopifnot(nrow(dtStatus) != 0)

coll <- dtStatus$coll[1]
scriptToRun <- DefScripts()[DefCollections() == coll]

commandToRun <- paste0("Rscript ", scriptToRun," 50 >",sub(".R", ".log", scriptToRun))
print(paste0("Running: ", commandToRun))
system(commandToRun, wait=FALSE)