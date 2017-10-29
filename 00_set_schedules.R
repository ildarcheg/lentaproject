source("00_dbmongo.R", quietly = TRUE)

scheduleCollection$find()

commandArgs <- function() c("1999-09-01", "2001-12-31")
source('00_add_days.R')

crontabToAdd <- c()
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 00; Rscript 00_log_cpu.R # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 10; Rscript 00_log_cpu.R # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 20; Rscript 00_log_cpu.R # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 30; Rscript 00_log_cpu.R # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 40; Rscript 00_log_cpu.R # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 50; Rscript 00_log_cpu.R # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 00; Rscript 00_run_processes.R # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 10; Rscript 00_run_processes.R # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 20; Rscript 00_run_processes.R # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 30; Rscript 00_run_processes.R # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 40; Rscript 00_run_processes.R # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, '* *   * * *   cd /home/ildar/lentaproject/; sleep 50; Rscript 00_run_processes.R # LENTA R SCRIPT')

#crontabToAdd <- c()
crontab <- system('crontab -l', intern = TRUE)
lentaCron <- grep("# LENTA", crontab)
if (length(lentaCron)!=0) {crontab <- crontab[-lentaCron]}
crontab <- c(crontab, crontabToAdd)
writeLines(crontab, "current_cron")
crontab <- system('crontab current_cron', intern = TRUE)
