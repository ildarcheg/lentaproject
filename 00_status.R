source("00_utils.R")
dtStatus <- GetDBStatusCLI()
cpu <- GetCPULoadFromLog()
dt <- GetPerformanceCLI()

print(paste0("---------------------"))
print(paste0("START: ", format(Sys.time(), "%Y-%m-%d-%H-%M-%S %Z")))

print(paste0("CPU: ", cpu))
if (nrow(dt)==0) {
  print(paste0("ALREADY STARTED PROCESSES: no processes found")) 
} else {
  print(paste0("ALREADY STARTED PROCESSES:"))
  print(as.data.frame(dt))
}
print(paste0("CURRENT DB STATUS:"))
print(dtStatus)