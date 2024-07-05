#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(markdown)

navbarPage("Navbar!",
           tabPanel("About", 
                    img(src = "afl_logo.png", align = "top"),
                    markdown("
                             # About Title
                             Some text goes **here**.
                             ")),
           tabPanel("Data Table",
                    sidebarLayout(
                      sidebarPanel(
                        markdown("## Data options"),
                        sliderInput("year", "Year", 2021, lubridate::year(Sys.Date()), value = 2021),
                        numericInput("round", "Round", value = NULL, min = 1, max = 28),
                        selectInput("team", "Team", 
                                    choices = 
                                      list(
                                        All = NA,
                                        ADE = 1,
                                        BRI = 2,
                                        CAR = 3,
                                        COL = 4,
                                        ESS = 5,
                                        FRE = 6,
                                        GEE = 7,
                                        GCS = 8,
                                        GWS = 9,
                                        HAW = 10,
                                        MEL = 11,
                                        NOR = 12,
                                        POR = 13,
                                        RIC = 14,
                                        STK = 15,
                                        SYD = 16,
                                        WCE = 17,
                                        WBD = 18
                                      )
                                    ),
                        numericInput("percent", "Percent Complete", value = NULL, min = 0, max = 100),
                        numericInput("live", "Live Game Indicator", value = 0, min = 0, max = 1),
                        checkboxGroupInput("columns", "Columns to Keep",
                                           choices = c("winner", "abehinds", "complete", "id", "localtime", "agoals", 
                                             "date", "hgoals", "venue", "is_final", "hbehinds", "hteam", "hteamid", 
                                             "timestr", "year", "winnerteamid", "updated", "hscore", "is_grand_final", 
                                             "unixtime", "ascore", "roundname", "ateam", "tz", "round", "ateamid", 
                                             "local_month", "local_day", "local_dow", "local_hour", "local_minute", 
                                             "winner_designation"),
                                           selected = c("winner", "abehinds", "complete", "id", "localtime", "agoals", 
                                                        "date", "hgoals", "venue", "is_final", "hbehinds", "hteam", "hteamid", 
                                                        "timestr", "year", "winnerteamid", "updated", "hscore", "is_grand_final", 
                                                        "unixtime", "ascore", "roundname", "ateam", "tz", "round", "ateamid", 
                                                        "local_month", "local_day", "local_dow", "local_hour", "local_minute", 
                                                        "winner_designation")),
                        downloadButton("download", "Download Data")
                      ),
                      mainPanel(tableOutput("table"))
                    )),
           tabPanel("Data Exploration",
                    sidebarLayout(
                      sidebarPanel(
                        "Data Options"
                        ),
                      mainPanel("Contents")
                      )
                    ),
           tabPanel("Plot",
                    sidebarLayout(
                      sidebarPanel(
                        radioButtons("plotType", "Plot type",
                                     c("Scatter"="p", "Line"="l")
                        )
                      ),
                      mainPanel(
                        plotOutput("plot")
                      )
                    )
           )
)