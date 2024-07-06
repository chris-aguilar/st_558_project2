#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(markdown)
library(DT)

navbarPage("Navbar!",
           tabPanel("About", 
                    img(src = "afl_logo.png", align = "top"),
                    markdown("
                             # Welcome to the Aussie Rules Football Data App!
                             ## Introduction
                             This app allows users to pull data from the Aussie Rules Football API found [here.](https://api.squiggle.com.au/#section_games) The data corresponds to the `games` endpoint with parameters `year` and `team`.
                             Users can view/download data for a particular season and team at a time, as well as explore match outcomes and scores visually.
                             ## Packages needed
                             Run the following for the packages needed in this app: `install.packages('httr', 'jsonlite', shiny', 'tidyverse', 'lubridate', 'DT', 'markdown')`
                             ## Running this app remotely
                             Run the following code to access this app from your R session: `runGitHub('chris-aguilar/st_558_project2', subdir = 'st_558_project2_app')`
                             ")),
           tabPanel("Data Table",
                    sidebarLayout(
                      sidebarPanel(
                        markdown("## Data options"),
                        sliderInput("year", "Year", 2021, lubridate::year(Sys.Date()), value = 2021),
                        selectInput("team", "Team", 
                                    choices = 
                                      list(ADE = 1, BRI = 2, CAR = 3, COL = 4, ESS = 5, FRE = 6, GEE = 7, GCS = 8, GWS = 9, 
                                           HAW = 10, MEL = 11, NOR = 12, POR = 13, RIC = 14, STK = 15, SYD = 16, WCE = 17, WBD = 18
                                           )
                                    ),
                        checkboxGroupInput("columns", "Columns to Keep",
                                           choices = c("winner", "abehinds", "complete", "id", "localtime", "agoals", 
                                             "date", "hgoals", "venue", "is_final", "hbehinds", "hteam", "hteamid", 
                                            "year", "winnerteamid", "updated", "hscore", "is_grand_final", 
                                             "unixtime", "ascore", "roundname", "ateam", "tz", "round", "ateamid", 
                                             "local_month", "local_day", "local_dow", "local_hour", "local_minute", 
                                             "winner_designation"),
                                           selected = c("winner", "abehinds", "complete", "id", "localtime", "agoals", 
                                                        "date", "hgoals", "venue", "is_final", "hbehinds", "hteam", "hteamid", 
                                                        "year", "winnerteamid", "updated", "hscore", "is_grand_final", 
                                                        "unixtime", "ascore", "roundname", "ateam", "tz", "round", "ateamid", 
                                                        "local_month", "local_day", "local_dow", "local_hour", "local_minute", 
                                                        "winner_designation")),
                        downloadButton("download", "Download Data")
                      ),
                      mainPanel(DTOutput("table"))
                    )),
           tabPanel("Data Exploration",
                    sidebarLayout(
                      sidebarPanel(
                        sliderInput("expyear", "Year", 2021, lubridate::year(Sys.Date()), value = 2021),
                        selectInput("expteam", "Team", 
                                    choices = 
                                      list(ADE = 1, BRI = 2, CAR = 3, COL = 4, ESS = 5, FRE = 6, GEE = 7, GCS = 8, GWS = 9, 
                                           HAW = 10, MEL = 11, NOR = 12, POR = 13, RIC = 14, STK = 15, SYD = 16, WCE = 17, WBD = 18
                                      )
                        ),
                        selectInput("relation", "Relationship Type",
                                    c("univariate", "bivariate")
                                    ),
                      conditionalPanel(
                        condition = "input.relation == 'univariate'",
                        selectInput(
                          "univariable", "Select variable",
                          c("winner", "abehinds", "agoals", "hgoals", "hbehinds", "hteam", "hscore",
                            "unixtime", "ascore", "roundname", "ateam", "round", "winner_designation")
                            ),
                        checkboxGroupInput(
                          "choices", "Plot Options",
                          c("Group" = "winner_designation", "Facet" = "local_dow")
                          )
                        ),
                      conditionalPanel(
                        condition = "input.relation == 'bivariate'",
                        selectInput(
                          "x", "X variable",
                          c("winner", "abehinds", "agoals", "hgoals", "hbehinds", "hteam", "hscore",
                            "unixtime", "ascore", "roundname", "ateam", "round", "winner_designation")
                        ),
                        selectInput(
                          "y", "Y variable",
                          c("winner", "abehinds", "agoals", "hgoals", "hbehinds", "hteam", "hscore",
                            "unixtime", "ascore", "roundname", "ateam", "round", "winner_designation")
                        ),
                        checkboxGroupInput(
                          "choices", "Plot Options",
                          c("Group" = "winner_designation", "Facet" = "local_dow")
                        )
                      )
                    ),
                    mainPanel(plotOutput("plot"))
                    )
                  )
           )