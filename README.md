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

To automate this process and to make it scalable I used following techics. Using `00_set_schedules.R` script I setup cron jobs that runs `sar 1 5` every 10 seconds (to check CPU load) and `00_run_processes.R`, which checks CPU load and, if it is less than 75%, gets first 10 days drom `c01_daytobeprocessed` and runs `01_days_process.R`. At the same time the same script check out other collections and runs scripts related to that collections.

This is how DB looks like before adding dates to first collections (easily check it with helps of `00_status.R` script):
```
ildar@instance-1:~/lentaproject$ Rscript 00_status.R 
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

Rscript 00_add_days.R 2018-01-01 2018-06-30

How it looks right after adding the dates:
```
ildar@instance-1:~/lentaproject$ Rscript 00_status.R  
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
ildar@instance-1:~/lentaproject$ Rscript 00_status.R 
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

