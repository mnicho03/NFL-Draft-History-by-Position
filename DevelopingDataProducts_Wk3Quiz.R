#load libraries
library(plotly)
library(data.table)
library(dplyr)
library(rvest)
library(devtools)
library(ggplot2)

#assign draft data URL to variable and scrape HTML for the table using rvest package
draftURL <- "https://www.pro-football-reference.com/draft/draft-totals.htm"
draftOverview <- read_html(draftURL)

#scrape draft data and assign to data frame
Draft_Overview_Data <- draftOverview %>% 
        html_node("table") %>% 
        html_table(header = TRUE, fill = TRUE)

#filter dataset to just year and position pick totals
draft_pick_totals <- select(Draft_Overview_Data, c("Year", "QB", "RB", "WR", "TE", "OL", "DL", "LB", "DB", "ST"))

#filter to show since 1995 for consistency
#slight variations in total picks over time - between 240 and 262 in last 22 years
draft_pick_totals <- filter(draft_pick_totals, Year >= 1995)

#reformat to long data set for simpler plotting
draft_pick_totals_long <- melt(draft_pick_totals, 
                                id.vars = "Year",
                                measure.vars = c("QB", "RB", "WR", "TE", "OL", "DL", "LB", "DB", "ST"),
                                variable.name = "Position",
                                value.name = "Selections")
#update to data frame
setDF(draft_pick_totals_long)

#create plot
p <- ggplot(draft_pick_totals_long, aes(x = Year, y = Selections, color = Position)) +
        geom_point(alpha = .5) +
        geom_smooth(se = TRUE, method = "loess", alpha = .1, size = .05) + 
        labs(title = "NFL Draft Selections by Position Over Time", 
             subtitle = "1995 - 2017", 
             ylab = "Number of Selections",
             caption= "Source: pro-football-reference.com")

#convert to interactive plotly version 
ggplotly(p) %>% animation_opts(frame=1000,transition=600,redraw=T)  