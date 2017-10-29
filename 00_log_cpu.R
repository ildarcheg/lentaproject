require(stringr, quietly = TRUE)
require(tm, quietly = TRUE)
cpu <- system("sar 1 5", intern = TRUE)[9] %>% stripWhitespace %>% str_split(" ")
cpu <- cpu[[1]][3]
writeLines(cpu,"cpu_performance.log")