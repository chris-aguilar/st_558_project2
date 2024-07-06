
library(shiny)
library(DT)
source("helpers.R")

# Define server logic required to draw univariate and bivariate plots w/ group, facet options
function(input, output, session) {
    
    # data table tab
    inputData <- reactive({
      get_games(year = input$year, team = input$team)
      }
    )
  
    output$table <- renderDT({
      
      inputData()[, input$columns]
      
    })
    
    output$download <- downloadHandler(
      filename = function() {
        paste0(input$team, "_games_", input$year, ".csv")
        },
      content = function(file) {
        readr::write_csv(inputData()[, input$columns], file)
      }
    )
  
    # data exploration tab
    expData <- reactive({
      get_games(year = input$expyear, team = input$expteam)
      }
    )
    
    output$plot <- renderPlot({
      
      # plots based on relation type
        if(input$relation == "univariate"){
          # checking for numeric input variable, then checking for group/facet options
          if(is.numeric(expData()[[input$univariable]])){
            if(length(input$choices) == 0) {
              return(univar_plot(expData(), var = input$univariable))
            } else if(length(input$choices) == 2) {
              return(univar_plot(expData(), var = input$univariable, group_var = input$choices[1], facet_var = input$choices[2]))
            } else {
              if(input$choices == "winner_designation") {
                return(univar_plot(expData(), var = input$univariable, group_var = "winner_designation"))
                } else if(input$choices == "local_dow") {
                return(univar_plot(expData(), var = input$univariable, facet_var = "local_dow"))
                }
              } # same but for categorical variables
          } else if(length(input$choices) == 0) {
            return(bar_plot(expData(), y = input$univariable))
          } else if(length(input$choices) == 2) {
            return(bar_plot(expData(), y = input$univariable, group_var = input$choices[1], facet_var = input$choices[2]))
          } else {
            if(input$choices == "winner_designation") {
              return(bar_plot(expData(), y = input$univariable, group_var = "winner_designation"))
            } else if(input$choices == "local_dow") {
              return(bar_plot(expData(), y = input$univariable, facet_var = "local_dow"))
            }
          }
        }
      # bivariate plots, no grouping or faceting due to time constraints
      if(input$relation == "bivariate") {
        if(is.numeric(expData()[[input$x]]) & is.numeric(expData()[[input$y]])) {
        return(scatter_plot(expData(), input$x, input$y))
        } else if(is.character(expData()[[input$x]]) & is.character(expData()[[input$y]])) {
            return(heat_map(expData(), input$x, input$y, "hscore"))
        } else {
            return(box_plot(expData(), input$x, input$y))
          }
      }
      
      # No numeric summaries or contingency tables due to time constraints but those functions exist in the helpers.R file!
      
    })
}
