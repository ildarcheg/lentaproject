require(ggplot2)
require(dplyr, quietly = TRUE)
require(tidyr, quietly = TRUE)
require(lubridate, quietly = TRUE)
#library(extrafont)
#font_import() # Import all fonts
#fonts() # Print list of all fonts
fontFamilyImpact <- "Impact"

pagesRaw <- readRDS("pages.Rds")

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
    as.Date(Sys.time()),
    "1999-2017", 
    numberOfArticles, sep = "\n"), vjust = 0, hjust = 0, x = unit(0.15, "npc"), y = unit(0.11, "npc"), gp = gpar(fontfamily = "Impact", col = "#552683", cex = 0.8))
  dev.off()
}

Graph1 <- function(pagesOriginal) {
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
      plot.title = element_text(colour = "#552683", face = "bold", size = 25, hjust = 0.5, vjust = 1, family = fontFamilyImpact),
      axis.text = element_text(colour = "#E7A922", family = fontFamilyImpact),
      axis.text.x=element_blank(),
      axis.ticks.x=element_blank(),
      axis.title = element_text(colour = "#552683", face = "bold", size = 13, family = fontFamilyImpact),
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
    scale_x_continuous(breaks = unique(pages$year)) +
    geom_text(aes(label = year), y = 12, size = 5, angle = 90, family = fontFamilyImpact, colour = "#E7A922")
  result <- p1 + kobe_theme()
  result
}
