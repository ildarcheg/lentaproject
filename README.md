# Analyze This. Lenta.ru (part 1)

### Data Engineering

At some point at the project [LENTA.RU](https://github.com/ildarcheg/lenta/) I decided to do the same again but in a different way and to build a pipeline that allows to get the data in a realtime using cloud server. Also I chose MongoDB as a storage for grabbed data instead of keeping hundreds of thousands of files on disk.

I created 4 collections:
```
DefCollections <- function() {
  collections <- c("c01_daytobeprocessed", 
                   "c02_linkstobeprocessed", 
                   "c03_pagestobeprocessed", 
                   "c04_articlestobeprocessed")
  return(collections)
}
```

And 4 scripts:
```
DefScripts <- function() {
  scripts <- c("01_days_process.R", 
               "02_links_process.R", 
               "03_pages_process.R", 
               "04_articles_process.R")
  return(scripts)
}
```

`c01_daytobeprocessed` keeps list of the days that have to be processed. For example, if I need to process all articles in January, 2018, I just have to add 2018-01-01, 2018-01-02, .., 2018-01-31 to this collection.

`01_days_process.R` takes dates from `c01_daytobeprocessed` collection and gets all the links to the all articles that were post at those dates. Once links are extracted for the specific date, they are stored at `c02_linkstobeprocessed` collection with 'status0' ('to be processed'), and the date are marked as 'processed' (with 'status2') at `c01_daytobeprocessed` collection.

`02_links_process.R` takes articles links from `c02_linkstobeprocessed` and grab and parse all the information from articles pages. Once it is done, parsed articles are stored at `c03_pagestobeprocessed` with 'status0' ('to be processed') and processed links are marked as 'processed' (with 'status2') at `c02_linkstobeprocessed`.

`03_pages_process.R` takes parsed articles from `c03_pagestobeprocessed`, tidies them, does the stemming and stores articles in `c04_articlestobeprocessed` with 'status0' ('to be processed'). Once it is done parsed articles are marked as 'processed' (with 'status2') at `c03_pagestobeprocessed`.

Thus, adding period to `c01_daytobeprocessed`, I get all articles stored at `c04_articlestobeprocessed` in a while.

To automate this process and to make it scalable I used following technics. Using `00_set_schedules.R` script I setup cron jobs that runs `sar 1 5` every 10 seconds (to monitor CPU load) and `00_run_processes.R`, which checks CPU load and, if it is less than 75%, gets first 10 days drom `c01_daytobeprocessed` and runs `01_days_process.R`. At the same time the same script check out other collections and runs scripts related to that collections.

To see how everything looks before we start:
```
Rscript 00_status.R 
```
```
[1] "---------------------"
[1] "START: 2018-07-13-12-40-29 UTC"
[1] "CPU: 1.12"
[1] "ALREADY STARTED PROCESSES: no processes found"
[1] "CURRENT DB STATUS:"
                       coll total status0 status1 status2 processes Mb
1 c00_defaults                  1       0       0       0         0  0
2 c01_daytobeprocessed          0       0       0       0         0  0
3 c02_linkstobeprocessed        0       0       0       0         0  0
4 c03_pagestobeprocessed        0       0       0       0         0  0
5 c04_articlestobeprocessed     0       0       0       0         0  0
6 history                       0       0       0       0         0  0
7 problems                      0       0       0       0         0  0
ildar@instance-1:~/lentaproject$
```

To add first 6 months of 2018:
```
Rscript 00_add_days.R 2018-01-01 2018-06-30
```

How DB looks right after adding the dates:
```
[1] "---------------------"
[1] "START: 2018-07-13-12-42-35 UTC"
[1] "CPU: 0.6"
[1] "ALREADY STARTED PROCESSES: no processes found"
[1] "CURRENT DB STATUS:"
                       coll total status0 status1 status2 processes Mb
1 c00_defaults                  1       0       0       0         0  0
2 c01_daytobeprocessed        181     181       0       0         1  0
3 c02_linkstobeprocessed        0       0       0       0         0  0
4 c03_pagestobeprocessed        0       0       0       0         0  0
5 c04_articlestobeprocessed     0       0       0       0         0  0
6 history                       0       0       0       0         0  0
7 problems                      0       0       0       0         0  0
```

How it looks 5 min after adding the dates:
```
[1] "---------------------"
[1] "START: 2018-07-13-12-47-54 UTC"
[1] "CPU: 45.71"
[1] "ALREADY STARTED PROCESSES:"
              script   PID  cpu memory
1 02_links_process.R 26487   17    1.4
2 02_links_process.R 26789 25.5    1.3
3 03_pages_process.R 26323 18.8    1.4
4 03_pages_process.R 26641 21.1    1.4
5 03_pages_process.R 26955 33.5    1.4
6 03_pages_process.R 27122 68.6    1.2
[1] "CURRENT DB STATUS:"
                       coll total status0 status1 status2 processes Mb
1 c00_defaults                  1       0       0       0         0  0
2 c01_daytobeprocessed        181     161       0      20         1  0
3 c02_linkstobeprocessed     2028     928      21    1079         3  0
4 c03_pagestobeprocessed     1078     918      44     116         5 13
5 c04_articlestobeprocessed   116     116       0       0         1  3
6 history                       0       0       0       0         0  0
7 problems                      0       0       0       0         0  0
```

How it looks when finished:
```
[1] "---------------------"
[1] "START: 2018-07-14-09-38-56 UTC"
[1] "CPU: 0.8"
[1] "ALREADY STARTED PROCESSES: no processes found"
[1] "CURRENT DB STATUS:"
                       coll total status0 status1 status2 processes  Mb
1 c00_defaults                  1       0       0       0         0   0
2 c01_daytobeprocessed        186       0       0     186         1   0
3 c02_linkstobeprocessed    22387       0       0   22387         1   3
4 c03_pagestobeprocessed    22343       0       0   22343         1 661
5 c04_articlestobeprocessed 22343   22343       0       0         1 840
6 history                   19633       0       0       0         1 692
7 problems                      2       0       0       0         0   0
```

How it looks when daily update is enabled:
```
Setting LC_CTYPE failed, using "C" 
[1] "---------------------"
[1] "START: 2018-08-11-19-34-46 UTC"
[1] "CPU: 85.84"
[1] "ALREADY STARTED PROCESSES:"
              script   PID  cpu memory
1 03_pages_process.R 10284  5.4    0.7
2 03_pages_process.R 10406  5.6    0.7
3 03_pages_process.R 10819  9.3    0.6
4 03_pages_process.R 11005 13.9    0.6
[1] "CURRENT DB STATUS:"
                       coll  total status0 status1 status2 processes   Mb
1 c00_defaults                   0       0       0       0         0    0
2 c01_daytobeprocessed        1665       0       0    1665         1    0
3 c02_linkstobeprocessed    244299      46       0  244253         1   37
4 c03_pagestobeprocessed    243926      39      51  243836         6 3452
5 c04_articlestobeprocessed 243926  243926       0       0         1 5884
6 history                        0       0       0       0         1 6977
7 problems                       0       0       0       0         0    0
```

The core of this ETL is `cron` (time-based job scheduler). It is set up by `00_set_schedules.R` script and generally looks like:
```
* *   * * *   cd /home/ildar/lentaproject/; sleep 00; sar 1 5 -o cpu_temp.log > /dev/null 2>&1; sar -f cpu_temp$
* *   * * *   cd /home/ildar/lentaproject/; sleep 10; sar 1 5 -o cpu_temp.log > /dev/null 2>&1; sar -f cpu_temp$
* *   * * *   cd /home/ildar/lentaproject/; sleep 20; sar 1 5 -o cpu_temp.log > /dev/null 2>&1; sar -f cpu_temp$
* *   * * *   cd /home/ildar/lentaproject/; sleep 30; sar 1 5 -o cpu_temp.log > /dev/null 2>&1; sar -f cpu_temp$
* *   * * *   cd /home/ildar/lentaproject/; sleep 40; sar 1 5 -o cpu_temp.log > /dev/null 2>&1; sar -f cpu_temp$
* *   * * *   cd /home/ildar/lentaproject/; sleep 50; sar 1 5 -o cpu_temp.log > /dev/null 2>&1; sar -f cpu_temp$
* *   * * *   cd /home/ildar/lentaproject/; sleep 05; Rscript 00_run_processes.R > process_t.log; mv process_t.$
* *   * * *   cd /home/ildar/lentaproject/; sleep 15; Rscript 00_run_processes.R > process_t.log; mv process_t.$
* *   * * *   cd /home/ildar/lentaproject/; sleep 25; Rscript 00_run_processes.R > process_t.log; mv process_t.$
* *   * * *   cd /home/ildar/lentaproject/; sleep 35; Rscript 00_run_processes.R > process_t.log; mv process_t.$
* *   * * *   cd /home/ildar/lentaproject/; sleep 45; Rscript 00_run_processes.R > process_t.log; mv process_t.$
* *   * * *   cd /home/ildar/lentaproject/; sleep 55; Rscript 00_run_processes.R > process_t.log; mv process_t.$
1,16,31,46 * * * *   cd /home/ildar/lentaproject/; Rscript 00_back_to_stage.R # LENTA R SCRIPT
1,16,31,46 * * * *   cd /home/ildar/lentaproject/; Rscript 00_prepare_data_for_analisys.R # LENTA R SCRIPT
10,25,40,55 * * * *   cd /home/ildar/lentaproject/; bash send_report_to_web.sh # LENTA R SCRIPT
*/30 * * * *   cd /home/ildar/lentaproject/; Rscript 00_everyday_update.R # LENTA R SCRIPT
```

Jobs scheduled with this `cron` above run `sar` every 10 second for monitoring and logging CPU activity. Also it runs `00_run_processes.R` script that looks in all 4 collection for the objects that have to be processed (that have status = 0). Every 30 min it updates `c01_daytobeprocessed` with two dates - today and yesterday. Every 15 min it runs shell script `send_report_to_web.sh` and updates webpage. 

<iframe src="http://http://35.228.78.26/" frameborder="0"></iframe>
