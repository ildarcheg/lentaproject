require(jsonlite, quietly = TRUE)
require(data.table, quietly = TRUE)
require(lubridate, quietly = TRUE)
require(stringr, quietly = TRUE)
source("00_dbmongo.R")

numextract <- function(string){ 
  str_extract(string, "\\-*\\d+\\.*\\d*")
}

system.time(system("mongo lenta export_articles_01.js > articles_01.csv", intern = FALSE, wait = TRUE))
print(Sys.time())
col2 <- fread("articles_01.csv", stringsAsFactors = FALSE, encoding = "UTF-8")
print(Sys.time())
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

# pagesRaw$wordTrump <- str_count(pagesRaw$stemedPlaintext, 'трамп')
# pagesRaw$wordPutin <- str_count(pagesRaw$stemedPlaintext, 'путин')

# 
# print(Sys.time())
# system('mongoexport --db lenta --collection c04_articlestobeprocessed --type=csv --fields "link,linkDate,page.0.datetime,page.0.rubric,page.0.subrubric,page.0.authors
# ,page.0.authorLinks,page.0.stemedPlaintext" --out dataPart1.csv', wait=TRUE, ignore.stdout = TRUE, ignore.stderr = TRUE)
# print(Sys.time())
# col2 <- fread("dataPart1.csv", stringsAsFactors = FALSE, encoding = "UTF-8")
# print(Sys.time())
# col <- articlesCollection$find('{}', fields = '{"link":1, "linkDate":1, "page.datetime":1}')
# print(Sys.time())
# 
# for (i in (1:nrow(col))) {
#   pg <- col[1, ]$page[[1]]
#   if (nrow(pg) > 1) {
#     print(i)
#     print(col[1, ]$link)
#   }
# }
# 
# for (i in (1:nrow(col))) {
#   pg <- col[1, ]$page[[1]]
#   if (is.na(pg)) {
#     print(i)
#     print(col[1, ]$link)
#   }
# }
# 
# pages <- rbindlist(col$page, fill = TRUE)
# pages <- cbind(col$link, col$linkDate, pages, stringsAsFactors = FALSE)
# pages <- pages %>% 
#   rename(link = V1, linkDate = V2) %>% 
#   mutate(dt = ymd(linkDate)) %>% 
#   mutate(wordsN = str_count(stemedPlaintext," ")) %>%
#   select(-stemedPlaintext) %>%
#   mutate(datetime = ymd_hms(datetime, tz = "Europe/Moscow", quiet = TRUE))
# saveRDS(pages, "dataPart1.Rds")
