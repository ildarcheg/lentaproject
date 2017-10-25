source("00_dbmongo.R")

scheduleCollection$find()

commandArgs <- function() c("1999-09-01", "2001-12-31")
source('00_add_days.R')

crontabToAdd <- c()
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 00; Rscript 01_days_process.R 10 # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 15; Rscript 01_days_process.R 10 # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 30; Rscript 01_days_process.R 10 # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 45; Rscript 01_days_process.R 10 # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 00; Rscript 02_links_process.R 100 # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 15; Rscript 02_links_process.R 100 # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 30; Rscript 02_links_process.R 100 # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 45; Rscript 02_links_process.R 100 # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 00; Rscript 03_pages_process.R 100 # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 15; Rscript 03_pages_process.R 100 # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 30; Rscript 03_pages_process.R 100 # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 45; Rscript 03_pages_process.R 100 # LENTA R SCRIPT')

#crontabToAdd <- c()
crontab <- system('crontab -l', intern = TRUE)
lentaCron <- grep("# LENTA", crontab)
if (length(lentaCron)!=0) {crontab <- crontab[-lentaCron]}
crontab <- c(crontab, crontabToAdd)
writeLines(crontab, "current_cron")
crontab <- system('crontab current_cron', intern = TRUE)
