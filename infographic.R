require(ggplot2)
require(dplyr, quietly = TRUE)
require(tidyr, quietly = TRUE)
require(lubridate, quietly = TRUE)
require(stringr, quietly = TRUE)
library(grid)
library(gridExtra)

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
  grid.text("INFOGRAPHIC", y = unit(0.99, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#A9A8A7", cex = 12, alpha = 0.3))
  grid.text("LENTA.RU", y = unit(0.68, "npc"), gp = gpar(fontfamily = "Impact", col = "#E7A922", cex = 6.4))
  grid.text("BY ILDAR GABDRAKHMANOV", vjust = 0, y = unit(0.51, "npc"), gp = gpar(fontfamily = "Impact", col = "#552683", cex = 0.8))
  #grid.text("ANALYSIS WITH PROGRAMMING", vjust = 0, y = unit(0.913, "npc"), gp = gpar(fontfamily = "Impact", col = "#552683", cex = 0.8))
  #grid.text("lenta.report", vjust = 0, y = unit(0.906, "npc"), gp = gpar(fontfamily = "Impact", col = "#552683", cex = 0.8))
  grid.rect(gp = gpar(fill = "#E7A922", col = "#E7A922"), x = unit(0.5, "npc"), y = unit(0.24, "npc"), width = unit(1, "npc"), height = unit(0.48, "npc")) #E7A922
  grid.text("CATEGORY", y = unit(0.24, "npc"), x = unit(0.5, "npc"), vjust = .5, hjust = .5, gp = gpar(fontfamily = "Impact", col = "#CA8B01", cex = 13, alpha = 0.3))
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
    "1999-2017", 
    numberOfArticles, sep = "\n"), vjust = 0, hjust = 0, x = unit(0.15, "npc"), y = unit(0.11, "npc"), gp = gpar(fontfamily = "Impact", col = "#552683", cex = 0.8))
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
    scale_y_continuous(breaks = 1:10)
  
  p2 <- p1 + geom_text(aes(label = hourFormatted), y = 0.2, size = 5, family = fontFamilyImpact, colour = "#E7A922")
  result <- p2 + kobe_theme()
  ggsave(paste0(imagePath, "graph3.png"), width = 18, height = 6, dpi = 300, units = "in")
  
  p2 <- p1 + geom_text(aes(label = hourFormatted), y = 0.15, size = 2.5, family = fontFamilyImpact, colour = "#E7A922")
  result <- p2 + kobe_theme()
  ggsave(paste0(imagePath, "graph3_m.png"), width = 9, height = 6, dpi = 300, units = "in")
}