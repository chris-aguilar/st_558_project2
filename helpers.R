
# querying API
library(httr)
library(jsonlite)
library(tibble)
library(dplyr)

# We're doing Australian Rules Football!


# API Calls for data ------------------------------------------------------


# Endpoint 1: team data containing team debut year, abbrevation, id, logo and full name

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


