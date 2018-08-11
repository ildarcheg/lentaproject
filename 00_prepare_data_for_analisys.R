require(jsonlite, quietly = TRUE)
require(data.table, quietly = TRUE)
require(lubridate, quietly = TRUE)
require(stringr, quietly = TRUE)
source("00_dbmongo.R")

numextract <- function(string){ 
  str_extract(string, "\\-*\\d+\\.*\\d*")
}

# extract the data for further analyse
system.time(system("mongo lenta export_articles_01.js > articles_01.csv", intern = FALSE, wait = TRUE))
print(Sys.time())
col2 <- fread("articles_01.csv", stringsAsFactors = FALSE, encoding = "UTF-8")
print(Sys.time())

# transform the data in a way it will be use to prepare webpage with analysis
pages <- col2 %>% 
  mutate(dt = ymd(linkDate)) %>% 
  mutate(wordsN = str_count(stemedPlaintext," ")) %>%
  select(-stemedPlaintext) %>%
  rename(FB = social) %>% mutate(FB = as.numeric(numextract(FB))) %>% 
  rename(VK = V8) %>% mutate(VK = as.numeric(numextract(VK))) %>% 
  rename(OK = V9) %>% mutate(OK = as.numeric(numextract(OK))) %>% 
  rename(Com = V10) %>% mutate(Com = as.numeric(numextract(Com))) %>% 
  mutate(datetime = ymd_hms(datetime, tz = "Europe/Moscow", quiet = TRUE))
saveRDS(pages, "articles_01.Rds")
print(Sys.time())
pagesRaw <- readRDS("articles_01.Rds")
