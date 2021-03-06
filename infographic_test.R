require(jsonlite, quietly = TRUE)
require(data.table, quietly = TRUE)
require(lubridate, quietly = TRUE)
source("00_dbmongo.R")
library(grid)
library(gridExtra)


pagesRaw <- readRDS("pages.Rds")

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
  top_n(3) %>%
  as.data.frame() %>% filter(year %in% c(2015)) %>%
  arrange(year, -n) 

## TO FACTOR
p1 <- ggplot(data = pages, aes(x = rubric, y = n)) + 
  geom_bar(stat="identity", fill = "#552683") 
result <- p1 + kobe_theme()


pages <- pages %>% arrange(year, n) %>% top_n()
ggplot(data = pages, aes(x = rubric, y = n)) + 
  geom_bar(stat="identity", fill = "#552683") + 
  facet_wrap( ~ year, ncol = 4, nrow = 5)

p1
g <- arrangeGrob(p1, p1, p1)
ggsave("fffff.jpg", g)

p3 <- ggplot(data = dat, aes(x = reorder(x, rep(1:12, 3)), y = y3, group = factor(grp))) +
  geom_bar(stat = "identity", fill = "#552683") + coord_polar() + facet_grid(. ~ grp) +
  ylab("Y LABEL") + xlab("X LABEL") + ggtitle("TITLE OF THE FIGURE")
p3

%>%
  group_by(year) %>%
  summarise(n = mean(n)) %>%
  mutate(n = as.integer(n)) %>%
  as.data.frame()

pages1 <- pagesOriginal %>% 
  group_by(year, linkDate) %>% 
  count() %>% 
  as.data.frame() %>%
  group_by(year) %>%
  summarise(n = mean(n)) %>%
  mutate(n = as.integer(n)) %>%
  as.data.frame()

pages2 <- pagesOriginal %>% 
  select(year, wordsN) %>%
  group_by(year) %>%
  summarise(n = median(wordsN)) %>%
  mutate(n = as.integer(n)) %>%
  as.data.frame()

pages <- left_join(pages1, pages2, "year")
names(pages) <- c("year", "a", "w")


ggplot(data = pages, aes(x = year, y = n)) + 
  geom_bar(stat="identity", fill = "#552683") + 
  geom_text(aes(label = year), y = 12, size = 5, angle = 90, family = fontFamilyImpact, colour = "#E7A922")

linksCollection <- GetCollection(DefCollections()[2])
pagesCollection <- GetCollection(DefCollections()[3])
articlesCollection <- GetCollection(DefCollections()[4])

articlesCollection$count()

#col <- articlesCollection$find('{}', fields = '{"link":1, "linkDate":1, "page.rubric":1, "page.subrubric":1}', limit = 10000)
print(Sys.time())
col <- articlesCollection$find('{}', fields = '{"link":1, "linkDate":1, "page.datetime":1, "page.rubric":1, "page.subrubric":1, "page.authors":1, "page.authorLinks":1, "page.stemedPlaintext":1}')
print(Sys.time())
pages <- rbindlist(col$page, fill = TRUE)
pages <- cbind(col$link, col$linkDate, pages, stringsAsFactors = FALSE)
pages <- pages %>% 
  rename(link = V1, linkDate = V2) %>% 
  mutate(dt = ymd(linkDate)) %>% 
  mutate(wordsN = str_count(stemedPlaintext," ")) %>%
  select(-stemedPlaintext) %>%
  mutate(datetime = ymd_hms(datetime, tz = "Europe/Moscow", quiet = TRUE))
saveRDS(pages, "pages.Rds")
print(Sys.time())

# Generate Infographic in PDF format
fontFamilyImpact = "Impact"

vplayout <- function(x, y) viewport(layout.pos.row = x, layout.pos.col = y)

y1 <- round(rnorm(n = 36, mean = 7, sd = 2)) # Simulate data from normal distribution
y2 <- round(rnorm(n = 36, mean = 21, sd = 6))
y3 <- round(rnorm(n = 36, mean = 50, sd = 8))
x <- rep(LETTERS[1:12], 3)
grp <- rep(c("Grp 1", "Grp 2", "Grp 3"), each = 12)
dat <- data.frame(grp, x, y1, y2, y3)

###

library(ggplot2)
# Using default theme
p1 <- ggplot(data = dat, aes(x = x, y = y1)) + geom_bar(stat = "identity", fill = "#552683") +
  coord_flip() + ylab("Y LABEL") + xlab("X LABEL") + facet_grid(. ~ grp) +
  ggtitle("TITLE OF THE FIGURE")
p1

###

library(extrafont)
font_import() # Import all fonts
fonts() # Print list of all fonts

###

require(dplyr, quietly = TRUE)
require(tidyr, quietly = TRUE)
require(lubridate, quietly = TRUE)
pagesRaw <- readRDS("pages.Rds")
pages <- pagesRaw %>% 
  mutate(dt = ymd(linkDate))
  mutate(ym = quarter(dt, with_year = TRUE)) %>% 
  group_by(quarter) %>% 
  count()
  
  pages2 <- pagesRaw %>% 
    mutate(dt = ymd(linkDate)) %>% 
    mutate(year = year(dt), q = as.character(quarter(dt, with_year = FALSE)), month = month(dt))
  
  pages <- pages2 %>% 
    group_by(year, linkDate) %>% 
    count() %>% 
    as.data.frame() %>%
    group_by(year) %>%
    summarise(n = mean(n)) %>%
    mutate(n = as.integer(n)) %>%
    as.data.frame()
  
  fontFamilyImpact = "Impact"
  kobe_theme <- function() {
    theme(
      plot.background = element_rect(fill = "#E2E2E3", colour = "#E2E2E3"),
      panel.background = element_rect(fill = "#E2E2E3"),
      plot.title = element_text(colour = "#552683", face = "bold", size = 18, vjust = 1, family = fontFamilyImpact),
      axis.text = element_text(colour = "#E7A922", family = fontFamilyImpact),
      axis.title = element_text(colour = "#552683", face = "bold", size = 13, family = fontFamilyImpact),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(colour = "#E7A922"),
      panel.grid.minor.x = element_blank(),
      panel.grid.minor.y = element_blank()
    )
  }

  p1 <- ggplot(data = pages, aes(x = year, y = n)) + 
    geom_bar(stat="identity", fill = "#552683") + 
    ylab("Average number of articles per day") + 
    xlab("Year") + ggtitle("TITLE OF THE FIGURE") +
    scale_x_continuous(breaks = unique(pages$year)) +
    geom_text(aes(label = year), y = 8, size = 5, angle = 90, family = fontFamilyImpact, colour = "#E7A922")
  p1 + kobe_theme()
  
p1 <- ggplot(data = pages, aes(x = q, y = n)) + geom_bar(stat="identity") + facet_grid(. ~ year)
p1
p1 <- ggplot(data = pages, aes(x = year, y = n)) + geom_bar(stat="identity") + facet_wrap( ~ rubric, ncol = 4)
p1

p1 <- ggplot(data = pages, aes(x=year, y=n)) + geom_point()
p1

p3 <- ggplot(data = dat, aes(x = x, y = y3, group = factor(grp))) +
  geom_bar(stat = "identity", fill = "#552683") + coord_polar() + facet_grid(. ~ grp) +
  ylab("Y LABEL") + xlab("X LABEL") + ggtitle("TITLE OF THE FIGURE")
p3

###

kobe_theme <- function() {
  theme(
    #plot.background = element_rect(fill = "#E2E2E3", colour = "#E2E2E3"),
    panel.background = element_rect(fill = "#E2E2E3"),
    panel.background = element_rect(fill = "white"),
    axis.text = element_text(colour = "#E7A922", family = "Impact"),
    #plot.title = element_text(colour = "#552683", face = "bold", size = 18, vjust = 1, family = "Impact"),
    #axis.title = element_text(colour = "#552683", face = "bold", size = 13, family = "Impact"),
    panel.grid.major.x = element_line(colour = "#E7A922"),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    #strip.text = element_text(family = "Impact", colour = "white"),
    strip.background = element_rect(fill = "#E7A922"),
    axis.ticks = element_line(colour = "#E7A922")
  )
}
p1 <- ggplot(data = dat, aes(x = y1, y = x)) + geom_bar(y) +
  coord_flip() + ylab("Y LABEL") + xlab("X LABEL") + facet_grid(. ~ grp) +
  ggtitle("TITLE OF THE FIGURE")
p1 + kobe_theme()

# Configure Theme
kobe_theme <- function() {
  theme(
    #plot.background = element_rect(fill = "#E2E2E3", colour = "#E2E2E3"),
    #panel.background = element_rect(fill = "#E2E2E3"),
    panel.background = element_rect(fill = "white"),
    axis.text = element_text(colour = "#E7A922", family = "Impact"),
    plot.title = element_text(colour = "#552683", face = "bold", size = 18, vjust = 1, family = "Impact"),
    axis.title = element_text(colour = "#552683", face = "bold", size = 13, family = "Impact"),
    panel.grid.major.x = element_line(colour = "#E7A922"),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    #strip.text = element_text(family = "Impact", colour = "white"),
    strip.background = element_rect(fill = "#E7A922"),
    axis.ticks = element_line(colour = "#E7A922")
  )
}

###

x_id <- rep(12:1, 3) # use this index for reordering the x ticks
p1 <- ggplot(data = dat, aes(x = x, y = y1)) + geom_bar(stat = "identity", fill = "#552683") +
  coord_flip() + ylab("Y LABEL") + xlab("X LABEL") + facet_grid(. ~ grp) +
  ggtitle("TITLE OF THE FIGURE")
p1 + kobe_theme()

###

p2 <- ggplot(data = dat, aes(x = x, y = y2, group = factor(grp))) +
  geom_line(stat = "identity", aes(linetype = factor(grp)), size = 0.7, colour = "#552683") +
  ylab("Y LABEL") + xlab("X LABEL") + ggtitle("TITLE OF THE FIGURE")
p2

###

kobe_theme2 <- function() {
  theme(
    legend.position = "bottom", 
    #legend.title = element_text(family = "Impact", colour = "#552683", size = 10),
    legend.background = element_rect(fill = "#E2E2E3"),
    legend.key = element_rect(fill = "#E2E2E3", colour = "#E2E2E3"),
    legend.text = element_text(family = "Impact", colour = "#E7A922", size = 10),
    plot.background = element_rect(fill = "#E2E2E3", colour = "#E2E2E3"),
    panel.background = element_rect(fill = "#E2E2E3"),
    panel.background = element_rect(fill = "white"),
    axis.text = element_text(colour = "#E7A922", family = "Impact"),
    plot.title = element_text(colour = "#552683", face = "bold", size = 18, vjust = 1, family = "Impact"),
    axis.title = element_text(colour = "#552683", face = "bold", size = 13, family = "Impact"),
    panel.grid.major.y = element_line(colour = "#E7A922"),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    strip.text = element_text(family = "Impact", colour = "white"),
    strip.background = element_rect(fill = "#E7A922"),
    axis.ticks = element_line(colour = "#E7A922")
  )
}

###

p2 + kobe_theme2() + scale_linetype_discrete("GROUP")

###

p3 <- ggplot(data = dat, aes(x = reorder(x, rep(1:12, 3)), y = y3, group = factor(grp))) +
  geom_bar(stat = "identity", fill = "#552683") + coord_polar() + facet_grid(. ~ grp) +
  ylab("Y LABEL") + xlab("X LABEL") + ggtitle("TITLE OF THE FIGURE")
p3

###

p3 + kobe_theme2()

###

pushViewport(viewport(layout = grid.layout(4, 3)))

###

grid.rect(gp = gpar(fill = "#E2E2E3", col = "#E2E2E3"))

###

print(p1, vp = vplayout(1, 2))

###

print(p1, vp = vplayout(1, 1:3))

###


# Configure Theme
kobe_theme <- function() {
  theme(
    plot.background = element_rect(fill = "#E2E2E3", colour = "#E2E2E3"),
    panel.background = element_rect(fill = "#E2E2E3"),
    panel.background = element_rect(fill = "white"),
    axis.text = element_text(colour = "#E7A922", family = "Impact"),
    plot.title = element_text(colour = "#552683", face = "bold", size = 18, vjust = 1, family = "Impact"),
    axis.title = element_text(colour = "#552683", face = "bold", size = 13, family = "Impact"),
    panel.grid.major.x = element_line(colour = "#E7A922"),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_blank(),
    panel.grid.minor.y = element_blank(),
    strip.text = element_text(family = "Impact", colour = "white"),
    strip.background = element_rect(fill = "#E7A922"),
    axis.ticks = element_line(colour = "#E7A922")
  )
}

library(grid)
pdf("~/Documents/Infographics1.pdf", width = 10, height = 20)
grid.newpage() 
pushViewport(viewport(layout = grid.layout(4, 3)))
grid.rect(gp = gpar(fill = "#E2E2E3", col = "#E2E2E3"))
grid.text("INFOGRAPHIC", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = fontFamilyImpact, col = "#A9A8A7", cex = 12, alpha = 0.3))
grid.text("RProgramming", y = unit(0.94, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "#E7A922", cex = 6.4))
grid.text("BY AL-AHMADGAID B. ASAAD", vjust = 0, y = unit(0.92, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "#552683", cex = 0.8))
grid.text("ANALYSIS WITH PROGRAMMING", vjust = 0, y = unit(0.913, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "#552683", cex = 0.8))
grid.text("alstatr.blogspot.com", vjust = 0, y = unit(0.906, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "#552683", cex = 0.8))
print(p3, vp = vplayout(4, 1:3))
print(p1, vp = vplayout(3, 1:3))
print(p2, vp = vplayout(2, 1:3))
grid.rect(gp = gpar(fill = "#E7A922", col = "#E7A922"), x = unit(0.5, "npc"), y = unit(0.82, "npc"), width = unit(1, "npc"), height = unit(0.11, "npc"))
grid.text("CATEGORY", y = unit(0.82, "npc"), x = unit(0.5, "npc"), vjust = .5, hjust = .5, gp = gpar(fontfamily = fontFamilyImpact, col = "#CA8B01", cex = 13, alpha = 0.3))
grid.text("A VERY VERY VERY VERY LONG TITLE", vjust = 0, hjust = 0, x = unit(0.01, "npc"), y = unit(0.88, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "#552683", cex = 1.2))
grid.text("DATA INFO", vjust = 0, hjust = 0, x = unit(0.01, "npc"), y = unit(0.86, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "white", cex = 1.2))
grid.text(paste(
  "Syndicated to",
  "Source",
  "Author",
  "Maintainer",
  "Frequency of Update",
  "Granularity",
  "Temporal Date", sep = "\n"), vjust = 0, hjust = 0, x = unit(0.01, "npc"), y = unit(0.79, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "#552683", cex = 0.8))
grid.text(paste(
  "http://alstatr.blogspot.com",
  "http://alstatr.blogspot.com",
  "Analysis with Programming",
  "Al-Ahmadgaid B. Asaad",
  "Annually",
  "National",
  "2011-2013", sep = "\n"), vjust = 0, hjust = 0, x = unit(0.15, "npc"), y = unit(0.79, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "#552683", cex = 0.8))
dev.off()

# Generate Infographic in PNG Format
vplayout <- function(x, y) viewport(layout.pos.row = x, layout.pos.col = y)
png("~/Documents/Infographics1.png", width = 10, height = 20, units = "in", res = 500)
grid.newpage() 
pushViewport(viewport(layout = grid.layout(4, 3)))
grid.rect(gp = gpar(fill = "#E2E2E3", col = "#E2E2E3"))
grid.text("INFOGRAPHIC", y = unit(1, "npc"), x = unit(0.5, "npc"), vjust = 1, hjust = .5, gp = gpar(fontfamily = fontFamilyImpact, col = "#A9A8A7", cex = 12, alpha = 0.3))
grid.text("RProgramming", y = unit(0.94, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "#E7A922", cex = 6.4))
grid.text("BY AL-AHMADGAID B. ASAAD", vjust = 0, y = unit(0.92, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "#552683", cex = 0.8))
grid.text("ANALYSIS WITH PROGRAMMING", vjust = 0, y = unit(0.913, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "#552683", cex = 0.8))
grid.text("alstatr.blogspot.com", vjust = 0, y = unit(0.906, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "#552683", cex = 0.8))
print(p1, vp = vplayout(4, 1:3))
print(p1, vp = vplayout(3, 1:3))
print(p1, vp = vplayout(2, 1:3))
grid.rect(gp = gpar(fill = "#E7A922", col = "#E7A922"), x = unit(0.5, "npc"), y = unit(0.82, "npc"), width = unit(1, "npc"), height = unit(0.11, "npc"))
grid.text("CATEGORY", y = unit(0.82, "npc"), x = unit(0.5, "npc"), vjust = .5, hjust = .5, gp = gpar(fontfamily = fontFamilyImpact, col = "#CA8B01", cex = 13, alpha = 0.3))
grid.text("A VERY VERY VERY VERY LONG TITLE", vjust = 0, hjust = 0, x = unit(0.01, "npc"), y = unit(0.88, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "#552683", cex = 1.2))
grid.text("DATA INFO", vjust = 0, hjust = 0, x = unit(0.01, "npc"), y = unit(0.86, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "white", cex = 1.2))
grid.text(paste(
  "Syndicated to",
  "Source",
  "Author",
  "Maintainer",
  "Frequency of Update",
  "Granularity",
  "Temporal Date", sep = "\n"), vjust = 0, hjust = 0, x = unit(0.01, "npc"), y = unit(0.79, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "#552683", cex = 0.8))
grid.text(paste(
  "http://alstatr.blogspot.com",
  "http://alstatr.blogspot.com",
  "Analysis with Programming",
  "Al-Ahmadgaid B. Asaad",
  "Annually",
  "National",
  "2011-2013", sep = "\n"), vjust = 0, hjust = 0, x = unit(0.15, "npc"), y = unit(0.79, "npc"), gp = gpar(fontfamily = fontFamilyImpact, col = "#552683", cex = 0.8))
dev.off()