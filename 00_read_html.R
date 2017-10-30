require(rvest, quietly = TRUE)
require(jsonlite, quietly = TRUE)
require(dplyr, quietly = TRUE)

SetNAIfZeroLength <- function(param) {
  param <- param[!is.na(param)]
  paramLength <- length(param)
  if (paramLength==0) {param <- NA}
  return(param)
}

ReadComment <- function(link, archiveDay) {
  
  link <- "https://lenta.ru/news/2017/10/27/skrepi/"
  linkToRead <- paste0("https://c.rambler.ru/api/app/126/widget/init/?appId=126&xid=", 
                       URLencode(link , reserved = TRUE))
  pg <- read_html(linkToRead, encoding = "UTF-8")
  jsonReply <- pg %>% html_text() %>% fromJSON() 
  
  if (is.null(jsonReply$comments)) { return(data.frame()) }
  
  columnNames <- names(jsonReply$comments)
  columnsToKeep <- c("id", 
                     "hasLink", 
                     "hasGreyWord", 
                     "text", 
                     "moderation", 
                     "rating", 
                     "createdAt", 
                     "parentId", 
                     "sessionSourceIcon", 
                     "userId", 
                     "userpic", 
                     "displayName", 
                     "username",
                     "level",
                     "childrenCount",
                     "hasChild")
  columns <- intersect(columnNames, columnsToKeep)
  comments <- jsonReply$comments %>% select(columns)
  
  comments
}

ReadLink <- function(link, archiveDay) {
  
  pg <- read_html(link, encoding = "UTF-8")
  
  # Extract Title, Type, Description
  metaTitle <- html_nodes(pg, xpath=".//meta[@property='og:title']") %>%
    html_attr("content") %>% 
    SetNAIfZeroLength() 
  metaType <- html_nodes(pg, xpath=".//meta[@property='og:type']") %>% 
    html_attr("content") %>% 
    SetNAIfZeroLength()
  metaDescription <- html_nodes(pg, xpath=".//meta[@property='og:description']") %>% 
    html_attr("content") %>% 
    SetNAIfZeroLength()
  
  # Extract script contect that contains rubric and subrubric data
  scriptContent <- html_nodes(pg, xpath=".//script[contains(text(),'chapters: [')]") %>% 
    html_text() %>% 
    strsplit("\n") %>% 
    unlist()
  
  if (is.null(scriptContent[1])) {
    chapters <- NA
  } else if (is.na(scriptContent[1])) {
    chapters <- NA
  } else {
    chapters <- scriptContent[grep("chapters: ", scriptContent)] %>% unique()
  }
  
  articleBodyNode <- html_nodes(pg, xpath=".//div[@itemprop='articleBody']")
  
  # Extract articles body
  plaintext <- html_nodes(articleBodyNode, xpath=".//p") %>% 
    html_text() %>% 
    paste0(collapse="") 
  if (plaintext == "") {
    plaintext <- NA
  }
  
  
  # Extract links from articles body 
  plaintextLinks <- html_nodes(articleBodyNode, xpath=".//a") %>% 
    html_attr("href") %>% 
    unique() %>% 
    paste0(collapse=" ") %>%
    SetNAIfZeroLength()
  if (plaintextLinks == "") {
    plaintextLinks <- NA
  }
  
  # Extract links related to articles
  additionalLinks <- html_nodes(pg, xpath=".//section/div[@class='item']/div/..//a") %>% 
    html_attr("href") %>% 
    unique() %>% 
    paste0(collapse=" ") %>%
    SetNAIfZeroLength()
  if (additionalLinks == "") {
    additionalLinks <- NA
  }
  
  # Extract image Description and Credits
  imageNodes <- html_nodes(pg, xpath=".//div[@class='b-topic__title-image']")
  imageDescription <- html_nodes(imageNodes, xpath="div//div[@class='b-label__caption']") %>% 
    html_text() %>% 
    unique() %>% 
    SetNAIfZeroLength()
  imageCredits <- html_nodes(imageNodes, xpath="div//div[@class='b-label__credits']") %>% 
    html_text() %>% 
    unique() %>% 
    SetNAIfZeroLength() 
  
  # Extract video Description and Credits
  if (is.na(imageDescription)&is.na(imageCredits)) {
    videoNodes <- html_nodes(pg, xpath=".//div[@class='b-video-box__info']")
    videoDescription <- html_nodes(videoNodes, xpath="div[@class='b-video-box__caption']") %>% 
      html_text() %>% 
      unique() %>% 
      SetNAIfZeroLength()
    videoCredits <- html_nodes(videoNodes, xpath="div[@class='b-video-box__credits']") %>% 
      html_text() %>% 
      unique() %>% 
      SetNAIfZeroLength() 
  } else {
    videoDescription <- NA
    videoCredits <- NA
  }
  
  # Extract articles url
  url <- html_nodes(pg, xpath=".//head/link[@rel='canonical']") %>% 
    html_attr("href") %>% 
    SetNAIfZeroLength()
  
  # Extract authors
  authorSection <- html_nodes(pg, xpath=".//p[@class='b-topic__content__author']")
  authors <- html_nodes(authorSection, xpath="//span[@class='name']") %>% 
    html_text() %>% 
    SetNAIfZeroLength()
  if (length(authors) > 1) {
    authors <- paste0(authors, collapse = "|")
  }
  authorLinks <- html_nodes(authorSection, xpath="a") %>% html_attr("href") %>% SetNAIfZeroLength()
  if (length(authorLinks) > 1) {
    authorLinks <- paste0(authorLinks, collapse = "|")
  }
  
  # Extract publish date and time
  datetimeString <- html_nodes(pg, xpath=".//div[@class='b-topic__info']/time[@class='g-date']") %>% 
    html_text() %>% 
    unique() %>% 
    SetNAIfZeroLength()
  datetime <- html_nodes(pg, xpath=".//div[@class='b-topic__info']/time[@class='g-date']") %>% 
    html_attr("datetime") %>% unique() %>% SetNAIfZeroLength()
  if (is.na(datetimeString)) {
    datetimeString <- html_nodes(pg, xpath=".//div[@class='b-topic__date']") %>% 
      html_text() %>% 
      unique() %>% 
      SetNAIfZeroLength()
  }
  
  data.frame(url = url,
             metaTitle= metaTitle,
             metaType= metaType,
             metaDescription= metaDescription,
             chapters = chapters,
             datetime = datetime,
             datetimeString = datetimeString,
             plaintext = plaintext, 
             authors = authors, 
             authorLinks = authorLinks,
             plaintextLinks = plaintextLinks,
             additionalLinks = additionalLinks, 
             imageDescription = imageDescription,
             imageCredits = imageCredits,
             videoDescription = videoDescription,
             videoCredits = videoCredits,
             stringsAsFactors=FALSE)
  
}