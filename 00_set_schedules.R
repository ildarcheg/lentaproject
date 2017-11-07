source("00_dbmongo.R")

crontabToAdd <- c()

timer <- formatC(seq(0, 59, 10), width = 2, format = "d", flag = "0")
for (i in 1:length(timer)) {
  cron <- paste0('* *   * * *   cd /home/ildar/lentaproject/; sleep ', timer[i], '; sar 1 5 -o cpu_temp.log > /dev/null 2>&1; sar -f cpu_temp.log > cpu.log; rm cpu_temp.log # LENTA R SCRIPT')
  crontabToAdd <- c(crontabToAdd, cron)
}

timer <- formatC(seq(0, 59, 3), width = 2, format = "d", flag = "0")
for (i in 1:length(timer)) {
  cron <- paste0('* *   * * *   cd /home/ildar/lentaproject/; sleep ', timer[i], '; Rscript 00_run_processes.R > process_t.log; mv process_t.log process.log # LENTA R SCRIPT')
  crontabToAdd <- c(crontabToAdd, cron)
}

cron <- paste0('1,30 * * * *   cd /home/ildar/lentaproject/; Rscript 00_back_to_stage.R # LENTA R SCRIPT')
crontabToAdd <- c(crontabToAdd, cron)

#crontabToAdd <- c()
crontab <- system('crontab -l', intern = TRUE)
lentaCron <- grep("# LENTA", crontab)
if (length(lentaCron)!=0) {crontab <- crontab[-lentaCron]}
crontab <- c(crontab, crontabToAdd)
writeLines(crontab, "current_cron")
crontab <- system('crontab current_cron', intern = TRUE)
