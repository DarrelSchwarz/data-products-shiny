#
# Market Data
#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# @Author: Darrel Schwarz
# @Date: 12th August 2019
#

library(shiny)
library(plotly)

tickerList <- c("AAPL","GOOG","IBM","MSFT","ORCL")
# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # Application title
    titlePanel("Market Data Analysis"),
    
    tags$head(tags$style(".shiny-notification {position: fixed; top: 20% ;left: 40%; color: blue")),

    plotlyOutput("distPlot"),

    hr(),
    
    h4("Pick two stocks to compare to the SP500"),
    fixedRow(
        column(3, selectInput(inputId = "tickerInput1", label = "Stock 1", choices = tickerList, selected = "AAPL")),
        column(3, selectInput(inputId = "tickerInput2", label = "Stock 2", choices = tickerList, selected = "GOOG"))),
    
    tabsetPanel(type = "tabs",
                tabPanel("Historical Investment Comparision", 
                         h3("Investment comparison for the selected stocks and period"),
                         h4("Enter initial investment amount and date range"),
                         numericInput("invest", "Investment amount ($US):", 2000, min = 1, max = 10000000000),
                         
                         dateRangeInput('dateRange1',
                                        label = paste('Date range'),
                                        start = "2007-01-01", end = Sys.Date(),
                                        min = "2007-01-01", max = Sys.Date(),
                                        separator = " - ", format = "dd/mm/yy",
                                        startview = 'month', language = 'en', weekstart = 1
                         ),
                         dataTableOutput('table'),
                         h6("* values calculated using closing price for the day")
                ),
                tabPanel("Timeseries Data", 
                         h3("Enter date range to browse daily market information for the stocks selected"),
                         
                         dateRangeInput('dateRange2',
                                        label = paste('Date range'),
                                        start = Sys.Date() - 7, end = Sys.Date(),
                                        min = "2007-01-01", max = Sys.Date(),
                                        separator = " - ", format = "dd/mm/yy",
                                        startview = 'month', language = 'en', weekstart = 1
                         ),
                         shiny::dataTableOutput('table2'))
            
    ),
    
    hr(),
    h6("* prices sourced from 'Yahoo' using 'quantmod' library and plotted using 'plotly'"),
    h6("** prices have not been adjusted for inflation")
))
