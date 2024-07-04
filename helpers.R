
# querying API
library(httr)
library(jsonlite)
library(tibble)
library(dplyr)
library(lubridate)

# We're doing Australian Rules Football!


# API Calls for data ------------------------------------------------------


# Endpoint 1: team data containing team debut year, abbrevation, id, logo and full name
# optional parameters: Team ID {team}, Debut Year {year}
get_teams <- function(...) {
  
  url <- 'https://api.squiggle.com.au/'
  q <- 'teams'
  
  # search parameters
  query <- list(q = q, ...)
  
  # api call
  api_return <- GET(url = url, query = query)
  
  # parsing results
  parsed_result <- fromJSON(rawToChar(api_return$content))
  
  # putting results into tibble for analysis
  parsed_result$teams |> tibble::as_tibble()
}

# Endpoint 2: info about one or more games
# optional parameters: year, round, game id, team id, complete, live
get_games <- function(year = NULL, ...) {
  
  url <- 'https://api.squiggle.com.au/'
  q <- 'games'
  if(is.null(year)) year <- format(Sys.Date(), "%Y") |> as.integer()
  
  # search parameters
  query <- list(q = q, year = year, ...)
  
  # api call
  api_return <- GET(url = url, query = query)
  
  # parsing results
  parsed_result <- fromJSON(rawToChar(api_return$content))
  
  # putting results into tibble for analysis
  parsed_result$games |> 
    tibble::as_tibble() |> 
    filter(!is.na(timestr)) |> # dropping games in the future
    mutate(
      local_month = month(localtime),
      local_day = day(localtime),
      local_dow = wday(localtime, label = TRUE, abbr = TRUE),
      local_hour = hour(localtime),
      local_minute = minute(localtime),
      winner_designation = ifelse(
        hscore == ascore, "Draw", 
        ifelse(winner == ateam, 
               "Away", ifelse(winner == hteam, "Home", NA)))
    )
}


# Summarizations ----------------------------------------------------------

# game level
games_2024 <- get_games(year = 2024)

# CONTINGENCY TABLES
winner_tables <- function(df, type = "winner_designation") {
switch(type,
  # question: who wins more, home or away?
  winner_designation = table(df[, "winner_designation"]) |> sort(decreasing = TRUE),
  
  # question: which team wins most so far?
  winners = table(df[, "winner"]) |> sort(decreasing = TRUE),
  
  # question: what home teams win most?
  home_winners = table(df[, c("hteam", "winner_designation")]),
  
  # question: what away team wins most?
  away_winners = table(df[, c("ateam", "winner_designation")])
  )
}

# NUMERICAL SUMMARIES
# scores by different, preferably univariate groups
average_scores <- function(df, group_type = winner_designation) {
  
  df |>
    group_by({{group_type}}) |>
    summarize(
      avg_points_scored = mean(hscore),
      avg_goals_scored = mean(hgoals),
      avg_behinds_scored = mean(hbehinds),
      avg_points_allowed = mean(ascore),
      avg_goals_allowed = mean(agoals),
      avg_behinds_allowed = mean(abehinds))
}


# Plots -------------------------------------------------------------------

library(ggplot2)

# univariate numeric
p <- games_2024 |> ggplot(aes(hscore)) + geom_density()
p + facet_wrap(~ winner_designation)

univar_plot <- function(df, var, facet_var = NULL, group_var = NULL) {
  
  # assign variable to axis
  p <-  df |>
    ggplot(aes(get(var)))
  
  # set title if no group or facet
  if(is.null(group_var) & is.null(facet_var)) p <- p + labs(title = paste("Density of", var))
  
  # assign group to color fill
  if(!is.null(group_var)) p <- p + aes(fill = get(group_var))
  
  # create density plot
  p <- p + geom_density(alpha=0.5)
  
  
  # create facets as needed
  if(!is.null(facet_var)) p <- p + facet_wrap(vars(get(facet_var)))
  
  # assign proper titles
  if(!is.null(group_var) & !is.null(facet_var)) p <- p + labs(title = paste("Distribution of", var, "by", group_var), subtitle = paste("Facets:", facet_var))
  if(!is.null(facet_var)) p <- p + labs(title = paste("Distribution of", var, "by", facet_var))
  if(!is.null(group_var)) p <- p + labs(title = paste("Distribution of", var, "by", group_var), fill = group_var)
  
  p + xlab(var)
}

# scatterplot

scatter_plot <- function(df, x, y, facet_var = NULL, group_var = NULL) {
  
  p <- df |>
    ggplot(aes(get(x), get(y))) 
  
  # set title if no group or facet
  if(is.null(group_var) & is.null(facet_var)) p <- p + labs(title = paste(y, "by", x))
  
  # assign color to group
  if(!is.null(group_var)) p <- p + aes(color = get(group_var))
  
  # create scatter plot
  p <- p + geom_point()
  
  # create facets as needed
  if(!is.null(facet_var)) p <- p + facet_wrap(vars(get(facet_var)))
  
  # assign proper titles
  if(!is.null(group_var) & !is.null(facet_var)) p <- p + labs(title = paste(y, "by", x, "for", group_var), subtitle = paste("Facets:", facet_var))
  if(!is.null(facet_var)) p <- p + labs(title = paste(y,"by", x, "for", facet_var))
  if(!is.null(group_var)) p <- p + labs(title = paste(y, "by", x, "for", group_var), color = group_var)
  p + xlab(x) + ylab(y)
}

# box plot

box_plot <- function(df, x, y, facet_var = NULL, group_var = NULL) {
  
  p <- df |>
    ggplot(aes(get(x), get(y))) 
  
  # set title if no group or facet
  if(is.null(group_var) & is.null(facet_var)) p <- p + labs(title = paste(y, "by", x))
  
  # assign color to group
  if(!is.null(group_var)) p <- p + aes(color = get(group_var))
  
  # create scatter plot
  p <- p + geom_boxplot()
  
  # create facets as needed
  if(!is.null(facet_var)) p <- p + facet_wrap(vars(get(facet_var)))
  
  # assign proper titles
  if(!is.null(group_var) & !is.null(facet_var)) p <- p + labs(title = paste(y, "by", x, "for", group_var), subtitle = paste("Facets:", facet_var))
  if(!is.null(facet_var)) p <- p + labs(title = paste(y,"by", x, "for", facet_var))
  if(!is.null(group_var)) p <- p + labs(title = paste(y, "by", x, "for", group_var), color = group_var)
  p + xlab(x) + ylab(y)
}

# bar plot
bar_plot <- function(df, x, y, facet_var = NULL, group_var = NULL) {
  
  p <- df |>
    ggplot(aes(get(x), get(y))) 
  
  # set title if no group or facet
  if(is.null(group_var) & is.null(facet_var)) p <- p + labs(title = paste(y, "by", x))
  
  # assign color to group
  if(!is.null(group_var)) p <- p + aes(fill = get(group_var))
  
  # create scatter plot
  p <- p + geom_col(position="dodge")
  
  # create facets as needed
  if(!is.null(facet_var)) p <- p + facet_wrap(vars(get(facet_var)))
  
  # assign proper titles
  if(!is.null(group_var) & !is.null(facet_var)) p <- p + labs(title = paste(y, "by", x, "for", group_var), subtitle = paste("Facets:", facet_var))
  if(!is.null(facet_var)) p <- p + labs(title = paste(y,"by", x, "for", facet_var))
  if(!is.null(group_var)) p <- p + labs(title = paste(y, "by", x, "for", group_var), fill = group_var)
  p + xlab(x) + ylab(y)
  
}

# heat map

heat_map <- function(df, x, y, z, facet_var = NULL) {
  
  p <- df |>
    ggplot(aes(get(x), get(y), fill = get(z))) 
  
  # set title if no group or facet
  if(is.null(facet_var)) p <- p + labs(title = paste("Heatmap,", z), subtitle = paste(y, "by", x), fill = z)
  
  # create scatter plot
  p <- p + geom_tile()
  
  # create facets as needed
  if(!is.null(facet_var)) p <- p + facet_wrap(vars(get(facet_var)))
  
  # assign proper titles
  if(!is.null(facet_var)) p <- p + labs(title = paste("Heatmap,", z), subtitle = paste(y,"by", x, "for", facet_var, "facets"), fill = z)
  p + xlab(x) + ylab(y)
  
}

