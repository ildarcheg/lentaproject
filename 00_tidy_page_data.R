require(dplyr, quietly = TRUE)
require(tibble, quietly = TRUE)
require(tidyr, quietly = TRUE)
require(data.table, quietly = TRUE)
require(tldextract, quietly = TRUE)
require(stringr, quietly = TRUE)
require(tm, quietly = TRUE)
require(lubridate, quietly = TRUE)

TityData <- function(pages) {

  # SECTION 1
  # Create urlKey column as a key
  dtD <- pages %>% 
    add_column(urlKey = "", .before = "url") %>% 
    mutate(urlKey = gsub(":|\\.|/", "", link))
  
  # Function SplitChapters is used to process formatted chapter column and retrive rubric 
  # and subrubric  
  SplitChapters <- function(x) {
    splitOne <- strsplit(x, "lenta.ru:_")[[1]]
    splitLeft <- strsplit(splitOne[1], ",")[[1]]
    splitLeft <- unlist(strsplit(splitLeft, ":_"))
    splitRight <- strsplit(splitOne[2], ":_")[[1]]
    splitRight <- splitRight[splitRight %in% splitLeft]
    splitRight <- gsub("_", " ", splitRight)
    paste0(splitRight, collapse = "|")
  }
  
  # SECTION 2
  # Process chapter column to retrive rubric and subrubric
  # Column value such as:
  # chapters: ["Бывший_СССР","Украина","lenta.ru:_Бывший_СССР:_Украина:_Правительство_ФРГ_сочло_неприемлемым_создание_Малороссии"], // Chapters страницы
  # should be represented as rubric value "Бывший СССР" 
  # and subrubric value "Украина"
  fieldsToProcess <- c("chapters")
  fieldsExist <- all(is.element(fieldsToProcess, names(dtD)))
  if (fieldsExist) {
    dtD <- dtD %>% 
      mutate(chapters = gsub('\"|\\[|\\]| |chapters:', "", chapters)) %>%
      mutate(chaptersFormatted = as.character(sapply(chapters, SplitChapters))) %>%
      separate(col = "chaptersFormatted", into = c("rubric", "subrubric")
               , sep = "\\|", extra = "drop", fill = "right", remove = FALSE) %>%
      select(-chapters, -chaptersFormatted) 
  }
  
  # SECTION 3
  # Process imageCredits column and split into imageCreditsPerson 
  # and imageCreditsCompany
  # Column value such as: "Фото: Игорь Маслов / РИА Новости" should be represented
  # as imageCreditsPerson value "Игорь Маслов" and 
  # imageCreditsCompany value "РИА Новости"
  fieldsToProcess <- c("imageCredits")
  fieldsExist <- all(is.element(fieldsToProcess, names(dtD)))
  if (fieldsExist) {
    pattern <- 'Фото: |Фото |Кадр: |Изображение: |, архив|(архив)|©|«|»|\\(|)|\"'
    dtD <- dtD %>% 
      mutate(imageCredits = gsub(pattern, "", imageCredits)) %>%
      separate(col = "imageCredits", into = c("imageCreditsPerson", "imageCreditsCompany")
               , sep = "/", extra = "drop", fill = "left", remove = FALSE) %>%
      mutate(imageCreditsPerson = as.character(sapply(imageCreditsPerson, trimws))) %>%
      mutate(imageCreditsCompany = as.character(sapply(imageCreditsCompany, trimws))) %>%
      select(-imageCredits)
  }
  # SECTION 4
  # Function UpdateDatetime is used to process missed values in datetime column
  # and fill them up with date and time retrived from string presentation 
  # such as "13:47, 18 июля 2017" or from url such 
  # as https://lenta.ru/news/2017/07/18/frg/. Hours and Minutes set randomly
  # from 8 to 21 in last case
  UpdateDatetime <- function (datetime, datetimeString, linkDate) {
    datetimeNew <- datetime
    if (is.na(datetime)) { 
      if (is.na(datetimeString)) {
        H <- round(runif(1, 8, 21))
        M <- round(runif(1, 1, 59))
        S <- "00"
        datetimeString <- paste0(linkDate, " ", 
                                 paste0(c(H, M, S), collapse = ":"))
        datetimeNew <- ymd_hms(datetimeString, tz = "Europe/Moscow", quiet = TRUE)
      } else {
        timeHoursMinutes <- sub("\\,.*", "", datetimeString)
        datetimeString <- paste0(linkDate, " ", timeHoursMinutes, ":00")
        datetimeNew <- ymd_hms(datetimeString, tz = "Europe/Moscow", quiet = TRUE)
      }
    }  
    datetimeNew
  }
  
  # Process datetime and fill up missed values
  fieldsToProcess <- c("datetime")
  fieldsExist <- all(is.element(fieldsToProcess, names(dtD)))
  if (!fieldsExist) { dtD$datetime <- NA }
  fieldsToProcess <- c("datetimeString")
  fieldsExist <- all(is.element(fieldsToProcess, names(dtD)))
  if (!fieldsExist) { dtD$datetimeString <- NA }
  
  dtD <- dtD %>% 
    mutate(datetime = ymd_hms(datetime, tz = "Europe/Moscow", quiet = TRUE)) %>% 
    mutate(datetimeNew = mapply(UpdateDatetime, datetime, datetimeString, dateToUse)) %>%
    mutate(datetime = as.POSIXct(datetimeNew, tz = "Europe/Moscow",origin = "1970-01-01")) %>%
    select(-datetimeNew)
  
  # SECTION 5
  # Depricated. Rename metaTitle to title, remove columns that we do not need anymore  
  dtD <- dtD %>%
    as.data.table() 
  
  # SECTION 6
  # Clean additionalLinks and plaintextLinks
  symbolsToRemove <- "href=|-–-|«|»|…|,|•|“|”|\n|\"|,|[|]|<a|<br" 
  symbolsHttp <- "http:\\\\\\\\|:http://|-http://|.http://"
  symbolsHttp2 <- "http://http://|https://https://"
  symbolsReplace <- "[а-я|А-Я|#!]"
  
  fieldsToProcess <- c("plaintextLinks")
  fieldsExist <- all(is.element(fieldsToProcess, names(dtD)))
  if (fieldsExist) {
  dtD <- dtD %>% 
    mutate(plaintextLinks = gsub(symbolsToRemove,"", plaintextLinks)) %>%
    mutate(plaintextLinks = gsub(symbolsHttp, "http://", plaintextLinks)) %>%
    mutate(plaintextLinks = gsub(symbolsReplace, "e", plaintextLinks)) %>%
    mutate(plaintextLinks = gsub(symbolsHttp2, "http://", plaintextLinks))
  }
  fieldsToProcess <- c("additionalLinks")
  fieldsExist <- all(is.element(fieldsToProcess, names(dtD)))
  if (fieldsExist) {
    dtD <- dtD %>% 
      mutate(additionalLinks = gsub(symbolsToRemove,"", additionalLinks)) %>%
      mutate(additionalLinks = gsub(symbolsHttp, "http://", additionalLinks)) %>%
      mutate(additionalLinks = gsub(symbolsReplace, "e", additionalLinks)) %>%
      mutate(additionalLinks = gsub(symbolsHttp2, "http://", additionalLinks))    
  }
  # SECTION 7
  # Clean additionalLinks and plaintextLinks using UpdateAdditionalLinks 
  # function. Links such as:
  # "http://www.dw.com/ru/../B2 https://www.welt.de/politik/.../de/"
  # should be represented as "dw.com welt.de"
  
  # Function UpdateAdditionalLinks is used to process additionalLinks 
  # and plaintextLinks and retrive source domain name
  UpdateAdditionalLinks <- function(additionalLinks, url) {
    if (is.na(additionalLinks)) {
      return(NA)
    }
    
    additionalLinksSplitted <- gsub("http://|https://|http:///|https:///"," ", additionalLinks)
    additionalLinksSplitted <- gsub("http:/|https:/|htt://","", additionalLinksSplitted)
    additionalLinksSplitted <- trimws(additionalLinksSplitted)
    additionalLinksSplitted <- unlist(strsplit(additionalLinksSplitted, " "))
    additionalLinksSplitted <- additionalLinksSplitted[!additionalLinksSplitted==""]
    additionalLinksSplitted <- additionalLinksSplitted[!grepl("lenta.", additionalLinksSplitted)]
    #additionalLinksSplitted <- unlist(strsplit(additionalLinksSplitted, "/[^/]*$"))
    additionalLinksSplitted <- sub("/.*", "", additionalLinksSplitted)
    #additionalLinksSplitted <- paste0("http://", additionalLinksSplitted)
    if (!length(additionalLinksSplitted) == 0) {
      parsedDomain <- tryCatch(tldextract(additionalLinksSplitted), error = function(x) {data_frame(domain = NA, tld = NA)}) 
      parsedDomain <- parsedDomain[!is.na(parsedDomain$domain), ]
      if (nrow(parsedDomain)==0) {
        #print("--------")
        #print(additionalLinks)
        return(NA)
      }
      domain <- paste0(parsedDomain$domain, ".", parsedDomain$tld)
      domain <- unique(domain)
      domain <- paste0(domain, collapse = " ")
      return(domain)
    } else {
      return(NA)
    }    
  }
  
  # Retrive domain from external links using updateAdditionalLinksDomain 
  # function. Links such as:
  # "http://www.dw.com/ru/../B2 https://www.welt.de/politik/.../de/"
  # should be represented as "dw.com welt.de" 
  fieldsToProcess <- c("plaintextLinks")
  fieldsExist <- all(is.element(fieldsToProcess, names(dtD)))
  if (fieldsExist) {
    dtD <- dtD %>% 
      mutate(plaintextLinks = mapply(UpdateAdditionalLinks, plaintextLinks, url))
  }
  fieldsToProcess <- c("additionalLinks")
  fieldsExist <- all(is.element(fieldsToProcess, names(dtD)))
  if (fieldsExist) {
    dtD <- dtD %>% 
      mutate(additionalLinks = mapply(UpdateAdditionalLinks, additionalLinks, url))   
  }
  
  # SECTION 8
  # Clean title, descriprion and plain text. Remove puntuation and stop words.
  # Prepare for the stem step
  stopWords <- readLines("stop_words.txt", warn = FALSE, encoding = "UTF-8")
  
  fieldsToProcess <- c("metaDescription")
  fieldsExist <- all(is.element(fieldsToProcess, names(dtD)))
  if (!fieldsExist) { dtD$metaDescription <- NA }
  
  dtD <- dtD %>% as.tbl() %>% mutate(stemTitle = tolower(metaTitle), 
                                     stemMetaDescription = tolower(metaDescription), 
                                     stemPlaintext = tolower(plaintext))
  dtD <- dtD %>% as.tbl() %>% mutate(stemTitle = enc2utf8(stemTitle), 
                                     stemMetaDescription = enc2utf8(stemMetaDescription), 
                                     stemPlaintext = enc2utf8(stemPlaintext))
  dtD <- dtD %>% as.tbl() %>% mutate(stemTitle = removeWords(stemTitle, stopWords), 
                                     stemMetaDescription = removeWords(stemMetaDescription, stopWords), 
                                     stemPlaintext = removeWords(stemPlaintext, stopWords))
  dtD <- dtD %>% as.tbl() %>% mutate(stemTitle = removePunctuation(stemTitle), 
                                     stemMetaDescription = removePunctuation(stemMetaDescription), 
                                     stemPlaintext = removePunctuation(stemPlaintext))   
  dtD <- dtD %>% as.tbl() %>% mutate(stemTitle = str_replace_all(stemTitle, "\\s+", " "), 
                                     stemMetaDescription = str_replace_all(stemMetaDescription, "\\s+", " "), 
                                     stemPlaintext = str_replace_all(stemPlaintext, "\\s+", " "))    
  dtD <- dtD %>% as.tbl() %>% mutate(stemTitle = str_trim(stemTitle, side = "both"), 
                                     stemMetaDescription = str_trim(stemMetaDescription, side = "both"), 
                                     stemPlaintext = str_trim(stemPlaintext, side = "both"))
  
  dtD <- dtD %>% as.tbl() %>% mutate(stemedTitle = mapply(StemText, stemTitle)) %>%
    mutate(stemedMetaDescription = mapply(StemText, stemMetaDescription)) %>%
    mutate(stemedPlaintext = mapply(StemText, stemPlaintext)) %>%
    select(-stemTitle, -stemMetaDescription, -stemPlaintext)

  # for (i in 1:nrow(dtD)) {
  #   comments <- dtD$comments[i]
  #   commentsDF <- StringToDF(comments)
  #   
  #   if (is.character(commentsDF)&&(commentsDF == "")) { next }
  #   
  #   commentsDF <- commentsDF %>% as.tbl() %>% mutate(stemedText = mapply(StemText, text))
  #   dtD$comments[i] <- commentsDF %>% toJSON() %>% as.character()
  # }
  
  return(dtD)  
}

TityDataComments <- function(comments) {
  
  # SECTION 1
  # Create urlKey column as a key
  dtD <- comments
 
  dtD <- dtD %>% mutate(createdAt = ymd_hms(createdAt, tz = "Europe/Moscow", quiet = TRUE)) 
  
  stopWords <- readLines("stop_words.txt", warn = FALSE, encoding = "UTF-8")
  
  dtD <- dtD %>% as.tbl() %>% mutate(stemText = tolower(text)) %>% 
    mutate(stemText = enc2utf8(stemText)) %>%
    mutate(stemText = removeWords(stemText, stopWords)) %>% 
    mutate(stemText = removePunctuation(stemText)) %>%
    mutate(stemText = str_replace_all(stemText, "\\s+", " ")) %>%
    mutate(stemText = str_trim(stemText, side = "both"))
  
  dtD$stemedText <- StemText(dtD$stemText)
  dtD <- dtD %>% select(-stemText)
  
  return(dtD)  
}

StemText <- function(textToStem) {
  res <- system("./mystem -cl", intern = TRUE, input = textToStem)
  res <- gsub("[{}]", "", res)
  res <- gsub("(\\|[^ ]+)", "", res)
  res <- gsub("\\?", "", res)
  res <- gsub("\\s+", " ", res)
  return(res)
}
