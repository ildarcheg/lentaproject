source("00_dbmongo.R")

scheduleCollection$find()

commandArgs <- function() c("1999-09-01", "1999-09-20")
source('00_add_days.R')

crontabToAdd <- c()
crontabToAdd <- c(crontabToAdd, '*/1 *   * * *   cd /home/ildar/lentaproject/; Rscript 01_days_process.R 5 # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '*/1 *   * * *   cd /home/ildar/lentaproject/; Rscript 02_links_process.R 25 # LENTA R SCRIPT')
#crontabToAdd <- c()
crontab <- system('crontab -l', intern = TRUE)
lentaCron <- grep("# LENTA", crontab)
if (length(lentaCron)!=0) {crontab <- crontab[-lentaCron]}
crontab <- c(crontab, crontabToAdd)
writeLines(crontab, "current_cron")
crontab <- system('crontab current_cron', intern = TRUE)
