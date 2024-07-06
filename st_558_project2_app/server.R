#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(DT)
source("helpers.R")

# Define server logic required to draw a histogram
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

        univar_plot(expData(), var = input$univariable)
      
    })
}
