require(ggplot2)
require(dplyr, quietly = TRUE)
require(tidyr, quietly = TRUE)
require(lubridate, quietly = TRUE)
require(stringr, quietly = TRUE)
library(grid)
library(gridExtra)

require(jsonlite, quietly = TRUE)
source("00_dbmongo.R")

#library(extrafont)
#font_import() # Import all fonts
#fonts() # Print list of all fonts
fontFamilyImpact <- "Impact"

pagesRaw <- readRDS("articles_01.Rds")

pagesOriginal <- pagesRaw %>% 
  mutate(year = year(dt), month = month(dt))

CreateInfographicsLogo <- function(pagesOriginal, logoPath) {
  require(ggplot2)
  require(grid)
  require(gridExtra)
  
  numberOfArticles <- nrow(pagesOriginal)
  
  # Generate Infographic in PNG Format
  png(logoPath, width = 10, height = 4, units = "in", res = 500)
  grid.newpage()
  #pushViewport(viewport(layout = grid.layout(4, 3)))
  grid.rect(gp = gpar(fill = "white", col = "white")) #E2E2E3
  grid.text("INFOGRAPHIC", y = unit(0.99, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Anton", col = "#A9A8A7", cex = 12.8, alpha = 0.3))
  grid.text("LENTA.RU", y = unit(0.645, "npc"), gp = gpar(fontfamily = "Anton", col = "#E7A922", cex = 6.4))
  grid.text("BY ILDAR GABDRAKHMANOV", vjust = 0, y = unit(0.49, "npc"), gp = gpar(fontfamily = "Anton", col = "#552683", cex = 0.8))
  #grid.text("ANALYSIS WITH PROGRAMMING", vjust = 0, y = unit(0.913, "npc"), gp = gpar(fontfamily = "Impact", col = "#552683", cex = 0.8))
  #grid.text("lenta.report", vjust = 0, y = unit(0.906, "npc"), gp = gpar(fontfamily = "Impact", col = "#552683", cex = 0.8))
  grid.rect(gp = gpar(fill = "#E7A922", col = "#E7A922"), x = unit(0.5, "npc"), y = unit(0.24, "npc"), width = unit(1, "npc"), height = unit(0.47, "npc")) #E7A922
  grid.text("INFOGRAPHIC", y = unit(0.24, "npc"), x = unit(0.5, "npc"), vjust = .5, hjust = .5, gp = gpar(fontfamily = "Anton", col = "#CA8B01", cex = 13, alpha = 0.3))
  #grid.text("A VERY VERY VERY VERY LONG TITLE", vjust = 0, hjust = 0, x = unit(0.01, "npc"), y = unit(0.88, "npc"), gp = gpar(fontfamily = "Impact", col = "#552683", cex = 1.2))
  grid.text("DATA INFO", vjust = 0, hjust = 0, x = unit(0.01, "npc"), y = unit(0.41, "npc"), gp = gpar(fontfamily = "Impact", col = "white", cex = 1.2))
  grid.text(paste(
    "Source",
    "Author",
    "Frequency of Update",
    "Last update",
    "Years", 
    "Number of articles", sep = "\n"), vjust = 0, hjust = 0, x = unit(0.01, "npc"), y = unit(0.11, "npc"), gp = gpar(fontfamily = "Impact", col = "#552683", cex = 0.8))
  grid.text(paste(
    "http://www.lenta.ru",
    "Ildar Gabdrakhmanov",
    "Daily",
    Sys.time(),
    "2014-2018",
    numberOfArticles, sep = "\n"), vjust = 0, hjust = 0, x = unit(0.15, "npc"), y = unit(0.11, "npc"), gp = gpar(fontfamily = "Impact", col = "#552683", cex = 0.8))
  dev.off()
}

CreateInfographicsLogo2 <- function(pagesOriginal, logoPath) {
  require(ggplot2)
  require(grid)
  require(gridExtra)

  # getting 24 hours limit
  limitDay <- max(pagesOriginal$datetime, na.rm = TRUE) - 24*60*60
  pagesOriginalCopy <- pagesOriginal %>% filter(datetime >= limitDay) %>% mutate(share = (FB+VK+OK))
  
  # getting top commented article
  topComments <- pagesOriginalCopy %>% top_n(1, Com)
  articlesCollection <- GetCollection(DefCollections()[4])
  queryString <- ListToQuery(list(link = topComments$link[1]))
  articles <- articlesCollection$find(queryString)
  shortTo60 <- function(titleToShort) {
    if (nchar(titleToShort) > 60) {
      shortedTitle <- paste0(substr(titleToShort, start = 1, stop = 60), "...")
    } else {
      shortedTitle <- titleToShort
    }
    shortedTitle
  }
  topCommentedArticle <- paste0(shortTo60(articles$page[[1]]$metaTitle), " / ", articles$page[[1]]$rubric, " / ", articles$page[[1]]$datetime, " MSK")
  
  # getting top shared article
  topShared <- pagesOriginalCopy %>% top_n(1, share)
  queryString <- ListToQuery(list(link = topShared$link[1]))
  articles <- articlesCollection$find(queryString)
  topSharedArticle <- paste0(shortTo60(articles$page[[1]]$metaTitle), " / ", articles$page[[1]]$rubric, " / ", articles$page[[1]]$datetime, " MSK")  
  numberOfArticles <- nrow(pagesOriginalCopy)
  
  # getting putin and trump
  words <- c()
  for (i in 1:nrow(pagesOriginalCopy)) {
    queryString <- ListToQuery(list(link = pagesOriginalCopy$link[i]))
    articles <- articlesCollection$find(queryString)   
    words <- c(words, articles$page[[1]]$stemedPlaintext)
  }
  putinMentioned <- sum(str_count(words, "путин"))
  trumpMentioned <- sum(str_count(words, "трамп"))
  
  # Generate Infographic in PNG Format
  #logoPath <- 'tt.png'
  png(logoPath, width = 10, height = 1.5, units = "in", res = 500)
  grid.newpage()
  grid.rect(gp = gpar(fill = "white", col = "white")) #E2E2E3
  grid.text("LAST 24 HOURS", vjust = 0, y = unit(0.89, "npc"), gp = gpar(fontfamily = "Anton", col = "#552683", cex = 0.8))
  grid.text("2014-2018", vjust = 0, y = unit(0.00, "npc"), gp = gpar(fontfamily = "Anton", col = "#552683", cex = 0.8))
  grid.text(paste(
    "Most shared article:",
    "Most commented article:",
    "Articles published: ",
    "Putin mentioned (times):",
    "Trump mentioned (times):",
    "", sep = "\n"), vjust = 0, hjust = 0, x = unit(0.01, "npc"), y = unit(0.11, "npc"), gp = gpar(fontfamily = "Impact", col = "#552683", cex = 0.8))
  grid.text(paste(
    topCommentedArticle,
    topSharedArticle,
    numberOfArticles,
    putinMentioned,
    trumpMentioned,
    "", sep = "\n"), vjust = 0, hjust = 0, x = unit(0.20, "npc"), y = unit(0.11, "npc"), gp = gpar(fontfamily = "Impact", col = "#552683", cex = 0.8))
  dev.off()
}

Graph1 <- function(pagesOriginal, imagePath) {
  pages <- pagesOriginal %>% 
    group_by(year, linkDate) %>% 
    count() %>% 
    as.data.frame() %>%
    group_by(year) %>%
    summarise(n = mean(n)) %>%
    mutate(n = as.integer(n)) %>%
    as.data.frame()
  
  kobe_theme <- function() {
    theme(
      plot.background = element_rect(fill = "white", colour = "white"),
      panel.background = element_rect(fill = "white"),
      plot.title = element_text(colour = "#552683", face = "plain", size = 25, hjust = 0.5, vjust = 1, family = fontFamilyImpact),
      axis.text = element_text(colour = "#E7A922", family = fontFamilyImpact),
      axis.text.x=element_blank(),
      axis.ticks.x=element_blank(),
      axis.title = element_text(colour = "#552683", face = "plain", size = 13, family = fontFamilyImpact),
      axis.title.x = element_text(margin = margin(t = -10, r = 0, b = 0, l = 0)),
      axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(colour = "#E7A922"),
      panel.grid.minor.x = element_blank(),
      panel.grid.minor.y = element_blank()
    )
  }
  
  p1 <- ggplot(data = pages, aes(x = year, y = n)) + 
    geom_bar(stat="identity", fill = "#552683") + 
    xlab("Year") + 
    ylab("Articles per day") + 
    ggtitle("Average number of articles per day") +
    scale_y_continuous(breaks = c(0, 50, 100, 150, 200), limits = c(0, 200)) +
    scale_x_continuous(breaks = unique(pages$year)) +
    geom_text(aes(label = year), y = 12, size = 5, angle = 90, family = fontFamilyImpact, colour = "#E7A922")
  result <- p1 + kobe_theme()

  ggsave(paste0(imagePath, "graph1.png"), width = 9, height = 6, dpi = 300, units = "in")
  
}

Graph2 <- function(pagesOriginal, imagePath) {
  
  pages <- pagesOriginal %>% 
    select(year, wordsN) %>%
    group_by(year) %>%
    summarise(n = median(wordsN)) %>%
    mutate(n = as.integer(n)) %>%
    as.data.frame()
  
  kobe_theme <- function() {
    theme(
      plot.background = element_rect(fill = "white", colour = "white"),
      panel.background = element_rect(fill = "white"),
      plot.title = element_text(colour = "#552683", face = "plain", size = 25, hjust = 0.5, vjust = 1, family = fontFamilyImpact),
      axis.text = element_text(colour = "#E7A922", family = fontFamilyImpact),
      axis.text.x=element_blank(),
      axis.ticks.x=element_blank(),
      axis.title = element_text(colour = "#552683", face = "plain", size = 13, family = fontFamilyImpact),
      axis.title.x = element_text(margin = margin(t = -10, r = 0, b = 0, l = 0)),
      axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(colour = "#E7A922"),
      panel.grid.minor.x = element_blank(),
      panel.grid.minor.y = element_blank()
    )
  }
  
  p1 <- ggplot(data = pages, aes(x = year, y = n)) + 
    geom_bar(stat="identity", fill = "#552683") + 
    xlab("Year") + 
    ylab("Words per article") + 
    ggtitle("Average number of words per article") +
    scale_y_continuous(breaks = c(0, 50, 100, 150, 200), limits = c(0, 200)) +
    scale_x_continuous(breaks = unique(pages$year)) +
    geom_text(aes(label = year), y = 12, size = 5, angle = 90, family = fontFamilyImpact, colour = "#E7A922")
  result <- p1 + kobe_theme()
  #result
  ggsave(paste0(imagePath, "graph2.png"), width = 9, height = 6, dpi = 300, units = "in")
}

Graph3 <- function(pagesOriginal, imagePath) {
  
  pages <- pagesOriginal %>% 
    select(year, linkDate, datetime) %>%
    na.omit(cols="datetime")
  pages$hour <- hour(pages$datetime)
  
  pages <- pages%>%
    group_by(hour, linkDate) %>%
    count() %>%
    as.data.frame() %>%
    group_by(hour) %>%
    summarise(n = mean(n)) %>%
    mutate(n = as.integer(n)) %>%
    as.data.frame() %>% 
    mutate(hour = as.integer(hour))
  
  pages$hourFormatted <- paste0(formatC(pages$hour, width = 2, format = "d", flag = "0"),":00")
  
  kobe_theme <- function() {
    theme(
      plot.background = element_rect(fill = "white", colour = "white"),
      panel.background = element_rect(fill = "white"),
      plot.title = element_text(colour = "#552683", face = "plain", size = 25, hjust = 0.5, vjust = 1, family = fontFamilyImpact),
      axis.text = element_text(colour = "#E7A922", family = fontFamilyImpact),
      axis.text.x=element_blank(),
      axis.ticks.x=element_blank(),
      axis.title = element_text(colour = "#552683", face = "plain", size = 13, family = fontFamilyImpact),
      axis.title.x = element_text(margin = margin(t = -10, r = 0, b = 0, l = 0)),
      axis.title.y = element_text(margin = margin(t = 0, r = 10, b = 0, l = 0)),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(colour = "#E7A922"),
      panel.grid.minor.x = element_blank(),
      panel.grid.minor.y = element_blank()
    )
  }

  p1 <- ggplot(data = pages, aes(x = hour, y = n)) + 
    geom_bar(stat="identity", fill = "#552683") + 
    xlab("Hour") + 
    ylab("Articles per hour") + 
    ggtitle("Average number of articles per hour") +
    scale_x_continuous(breaks = unique(pages$hour)) +
    scale_y_continuous(breaks = 0:13)
  
  p2 <- p1 + geom_text(aes(label = hourFormatted), y = 0.2, size = 5, family = fontFamilyImpact, colour = "#E7A922")
  result <- p2 + kobe_theme()
  ggsave(paste0(imagePath, "graph3.png"), width = 18, height = 6, dpi = 300, units = "in")
  
  p2 <- p1 + geom_text(aes(label = hourFormatted), y = 0.15, size = 2.5, family = fontFamilyImpact, colour = "#E7A922")
  result <- p2 + kobe_theme()
  ggsave(paste0(imagePath, "graph3_m.png"), width = 9, height = 6, dpi = 300, units = "in")
}

Graph4 <- function(pagesOriginal, imagePath) {
  
  pagesOriginal <- pagesRaw %>% 
    mutate(year = year(dt), month = month(dt))
  
  pagesOriginal$rubric[pagesOriginal$rubric == "Финансы"] <- "Экономика и Финансы"
  pagesOriginal$rubric[pagesOriginal$rubric == "Экономика"] <- "Экономика и Финансы"
  
  pages <- pagesOriginal %>% 
    group_by(year, rubric) %>% 
    count() %>% 
    as.data.frame() %>%
    arrange(year, -n) %>%
    as.data.frame() %>%
    group_by(year) %>%
    top_n(10) %>%
    as.data.frame()

  kobe_theme <- function() {
    theme(
      plot.background = element_rect(fill = "white", colour = "white"),
      panel.background = element_rect(fill = "white"),
      plot.title = element_text(colour = "#552683", face = "plain", size = 10, hjust = 0.5, vjust = 1, family = fontFamilyImpact),
      axis.text = element_text(colour = "#E7A922", family = fontFamilyImpact, size = 9),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      axis.title = element_text(colour = "#552683", face = "plain", size = 12, family = fontFamilyImpact),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      panel.grid.major.x = element_blank(), #panel.grid.major.x = element_line(colour = "#E7A922"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.x = element_blank(),
      panel.grid.minor.y = element_blank()
    )
  }
  
  pages <- pages %>% filter(year != "1999")
  
  years <- unique(pages$year)
  years <- years[order(-years)]
  pList <- list()
  for (i in 1:length(years)) {
    currentYear <- years[i]
    pagesR <- pages %>% filter(year == currentYear) %>% select(-year) %>% arrange(-n)
    pagesR$rubric <- as.factor(pagesR$rubric)
    p1 <- ggplot(data = pagesR, aes(x = reorder(rubric, n), y = n)) + 
      geom_bar(stat="identity", fill = "#552683") + coord_flip() +
      ggtitle(currentYear) + 
      scale_y_continuous(breaks = c(0, 2500, 5000, 7500, 10000), limits = c(0, 20000)) + 
      geom_text(aes(label = rubric), size = 4, hjust = -0.1, family = fontFamilyImpact, colour = "#E7A922") + 
      kobe_theme()
    if (((i-1)%%5) == 0) {
      p1 <- p1 + xlab("Rubric") 
    } else {
      p1 <- p1 + xlab(" ") 
    }
    pList[[i]] <- p1
  }
  g <- arrangeGrob(grobs = pList, ncol = 5)
  ggsave(paste0(imagePath, "graph4.png"), plot = g, width = 18, height = 12, dpi = 300, units = "in")
  g <- arrangeGrob(grobs = pList, ncol = 1)
  ggsave(paste0(imagePath, "graph4_m.png"), plot = g, width = 9, height = 24, dpi = 300, units = "in")
  
}