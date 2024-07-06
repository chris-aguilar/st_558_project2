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

navbarPage("AFL Game Visualization",
           tabPanel("About", 
                    img(src = "afl_logo.png", align = "top"),
                    markdown("
                             # Welcome to the Aussie Rules Football Data App!
                             ## Introduction
                             This app allows users to pull data from the [Aussie Rules Football (AFL)](https://en.wikipedia.org/wiki/Australian_rules_football) API found [here.](https://api.squiggle.com.au/#section_games) The data corresponds to the `games` endpoint with parameters `year` and `team`.
                             Users can view/download data for a particular season and team at a time, as well as explore match outcomes and scores visually.
                             ### Tab: Data Table
                             This tab allows users to view and download data for subsets of teams and years. Users may select the columns they wish to import, and the year/team filter subsets rows to only those teams and seasons of interest.
                             ### Tab: Data Exploration
                             This tab allows users to view univariate and bivariate plots that account for the data type of the inputs. Only the univariate plots support grouping and faceting. Due to time constraints, there are no numerical summaries or contingency tables.
                             ## Packages needed
                             Run the following for the packages needed in this app: `install.packages('httr', 'jsonlite', shiny', 'tidyverse', 'lubridate', 'DT', 'markdown')`
                             ## Running this app remotely
                             Run the following code to access this app from your R session: `runGitHub('chris-aguilar/st_558_project2', subdir = 'st_558_project2_app')`
                             ## Assignment Disclosure
                             Due to time constraints, numerical summaries/contingency tables were not included in the app, but the code for these exists in the `helpers.R` file. 
                             Same for group/facet support for bivariate plots.
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
                        )
                      )
                    ),
                    mainPanel(plotOutput("plot"))
                    )
                  )
           )