x <- getwd()
y <- format(Sys.time(), "%Y%m%d%H%M%S")
write.csv(x, paste0("a", y, ".csv"))
