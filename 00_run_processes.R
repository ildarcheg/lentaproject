source("00_dbmongo.R")
cpu <- GetCPULoadFromLog()

stopifnot(cpu<85)

dt <- GetPerformance()
dtStatus <- GetDBStatus() %>% filter(coll != "c04_articlestobeprocessed") %>% filter(status0 != 0) %>% arrange(status1, -status0)
print(dtStatus)
stopifnot(nrow(dtStatus) != 0)

coll <- dtStatus$coll[1]
scriptToRun <- DefScripts()[DefCollections() == coll]

commandToRun <- paste0("Rscript ", scriptToRun," 100")
print(paste0("Running: ", commandToRun))
system(commandToRun, wait=FALSE)