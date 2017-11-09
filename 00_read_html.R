require(rvest, quietly = TRUE)
require(jsonlite, quietly = TRUE)
require(dplyr, quietly = TRUE)
require(stringr, quietly = TRUE)

SetNAIfZeroLength <- function(param) {
  param <- param[!is.na(param)]
  paramLength <- length(param)
  if (paramLength==0) {param <- NA}
  return(param)
}

ReadSocial <- function(link, archiveDay) {
  linkEncode <- URLencode(link , reserved = TRUE)
  linkToReadFB <- paste0("https://graph.facebook.com/?fields=engagement&access_token=144213186161556|oTvA5NHlj3DdBNmzjp8zwnf-JlA&ids=", linkEncode)
  linkToReadVK <- paste0("https://vk.com/share.php?act=count&index=1&url=", linkEncode, "&format=json")
  linkToReadOK <- paste0("https://connect.ok.ru/dk?st.cmd=extLike&uid=okLenta&ref=", linkEncode, "")
  linkToReadCom <- paste0("https://c.rambler.ru/api/app/126/comments-count?xid=", linkEncode, "")
  FB <- tryCatch(read_html(linkToReadFB) %>% html_text() %>% fromJSON(), error = function(x) {NA})
  if ((length(FB) == 0)|is.na(FB)) { FB <- 0 } else { FB <- FB[[1]]$engagement$share_count }
  VK <- tryCatch(read_html(linkToReadVK) %>% html_text() %>% str_replace_all(" |.*\\,|\\);", "") %>% as.integer(), error = function(x) {0})
  OK <-  tryCatch(read_html(linkToReadOK) %>% html_text() %>% str_replace_all(" |.*\\,|\\);|'", "") %>% as.integer(), error = function(x) {0})
  Com <- read_html(linkToReadCom) %>% html_text() %>% fromJSON()
  if (length(Com$xids) == 0) { Com <- 0 } else { Com <- Com$xids[[1]] }
  data.frame(FB = FB,
             VK= VK,
             OK= OK,
             Com= Com,
             stringsAsFactors=FALSE)
}

ReadComment <- function(link, archiveDay) {
  
  comments <- NA
  
  linkEncode <- URLencode(link , reserved = TRUE)
  linkToRead <- paste0("https://c.rambler.ru/api/app/126/widget/init/?appId=126&xid=", 
                       linkEncode)
  pg <- read_html(linkToRead, encoding = "UTF-8")
  textToJSON <- html_nodes(pg, xpath=".//p") %>% html_text()
  valid <- validate(textToJSON)[[1]]
  if (valid == FALSE) {
    return(comments)
  }
  
  jsonReply <- html_nodes(pg, xpath=".//p") %>% html_text() %>% fromJSON() 
  
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
  
  if (is.null(jsonReply$comments)|(length(jsonReply$comments)==0)) { 
    return(comments)
  } else {
    columnNames <- names(jsonReply$comments)
    columns <- intersect(columnNames, columnsToKeep)
    comments <- jsonReply$comments %>% select(columns) 
    comments <- as.data.frame(comments)
  }
  
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
  if (length(articleBodyNode) == 0) {
    articleBodyNode <- html_nodes(pg, xpath=".//div[@class='b-numeric-card-box__title']|.//div[@class='b-numeric-card-box__description']")  
    # Extract articles body
    plaintext <- articleBodyNode %>% 
      html_text() %>% 
      paste0(collapse=" ") 
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
  } else {
    # Extract articles body
    plaintext <- html_nodes(articleBodyNode, xpath=".//p") %>% 
      html_text() %>% 
      paste0(collapse=" ") 
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