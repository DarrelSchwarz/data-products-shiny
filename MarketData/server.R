#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# @Author: Darrel Schwarz
# @Date: 12th August 2019
#
library(shiny)
library(quantmod)
library(plotly)
library(lubridate)

shinyServer(function(input, output, session) ({
    # Data request and initail processing
    dataset <- reactive({
        validate(
            need(input$ticker1!=input$ticker2, "Please select two different stock codes")
        )
        withProgress(message = 'Getting Data... Please Wait', value = 0, {
                
            tsnames <- c("Date","Ticker","Open","High","Low","Close","Volume","Adjusted")
            getSymbols(c(input$ticker1,input$ticker2,"^GSPC"),src='yahoo',warnings=F)
            
            i = 1
            incProgress(1/4, detail = paste("Processing Data", i))
            
            dfa <- data.frame(Date=index(get(input$ticker1)), Ticker=input$ticker1, coredata(get(input$ticker1)))
            names(dfa) <- tsnames
            
            i = i +1
            incProgress(1/4, detail = paste("Processing Data", i))
            
            dfg <- data.frame(Date=index(get(input$ticker2)), Ticker=input$ticker2, coredata(get(input$ticker2)))
            names(dfg) <- tsnames
            
            i = i +1
            incProgress(1/4, detail = paste("Processing Data", i))
            
            dfs <- data.frame(Date=index(GSPC),Ticker="SP500",coredata(GSPC))
            names(dfs) <- tsnames
            
            rbind(dfa,dfg,dfs)
            
        })

    })
    # Timeseries Plot for selected stocks and SP500 
    output$distPlot <- renderPlotly({
        withProgress(message = 'Generating Plot', value = 4, {
            dff <- dataset()
            p <- dff %>% plot_ly(type = 'scatter', mode = 'lines') %>%
                add_trace(x=~Date, y=~Close, name=input$ticker1,
                          line=list(color="green"),
                          data=dff[dff$Ticker==input$ticker1,]) %>%
                add_trace(x=~Date, y=~Close, name=input$ticker2,
                          line=list(color="lightblue"),
                          data=dff[dff$Ticker==input$ticker2,]) %>%
                add_trace(x=~Date, y=~Close, name="SP500",yaxis = "y2",
                          line=list(color="lightgreen"),
                          data=dff[dff$Ticker=="SP500",]) %>%
                layout(title = "Closing Market Prices",
                   xaxis = list(title = "Dates"),
                   yaxis = list(title = "Stock Price ($US)"),
                   yaxis2 = list(title = "SP500", side = "right", overlaying = "y"))
            p
            
        })
    })
    
    # Table 1 - Profit/Loss for period
    output$table <- shiny::renderDataTable({
        dff <- dataset()
        tic <- c(input$ticker1,input$ticker2,"SP500")
        wdfs <- dff[dff$Date >=input$dateRange1[1]& dff$Date <=input$dateRange1[2],]
        
        mind <- min(date(wdfs$Date))
        maxd <- max(date(wdfs$Date))
        
        wdfs2 <- wdfs[wdfs$Date %in% c(mind,maxd) & 
                      wdfs$Ticker %in% tic,]
        
        initc <- wdfs2$Close[wdfs2$Date==mind & wdfs2$Ticker%in% tic]
        finalc <- wdfs2$Close[wdfs2$Date==maxd & wdfs2$Ticker%in% tic]
        
        initq <- trunc(input$invest/initc,0) # initial quantity
        initv <- round(initq * initc,2)      # initial value
        finalv <- round(initq * finalc,2)    # final value
        prof <- finalv - initv               # profit
        pprof <- round(finalv/initv*100,2)   # profit percentage
        
        as.data.frame(list(Ticker=unique(wdfs2$Ticker),
                           Quantity=initq,
                           InitialValue=initv,
                           CurrentValue=finalv,
                           Profit=prof, 
                           Percentage=pprof)) 
    
    })
    # Table2 - Market Data for selected stocks and SP500
    output$table2 <- shiny::renderDataTable({
        dff <- dataset()
        dff[dff$Date >=input$dateRange2[1] & dff$Date <=input$dateRange2[2] & 
            dff$Ticker %in% c(input$ticker1,input$ticker2,"SP500"),]
    })
})
)
