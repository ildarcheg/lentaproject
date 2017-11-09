source("00_dbmongo.R")

commandArgs <- function() c(as.Date(Sys.time())-3, as.Date(Sys.time()))
source('00_add_days.R')