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

shinyServer(function(input, output) ({
    # Data request and initail processing 
    withProgress(message = 'Getting Data... Please Wait', value = 0, {
        
        tsnames <- c("Date","Ticker","Open","High","Low","Close","Volume","Adjusted")
        getSymbols(c("GOOG","AAPL","IBM","^GSPC","MSFT","ORCL"),src='yahoo',warnings=F)

        i = 1
        incProgress(1/7, detail = paste("Processing Data", i))

        dfb <- data.frame(Date=index(GSPC),Ticker="^GSPC",coredata(GSPC))
        names(dfb) <- tsnames
        dfb$Ticker <- "SP500"

        i = i +1
        incProgress(1/7, detail = paste("Processing Data", i))

        dfg <- data.frame(Date=index(GOOG),Ticker="GOOG",coredata(GOOG))
        names(dfg) <- tsnames
        
        i = i +1
        incProgress(1/7, detail = paste("Processing Data", i))

        dfi <- data.frame(Date=index(IBM),Ticker="IBM",coredata(IBM))
        names(dfi) <- tsnames
        
        i = i +1
        incProgress(1/7, detail = paste("Processing Data", i))

        dfa <- data.frame(Date=index(AAPL),Ticker="AAPL",coredata(AAPL))
        names(dfa) <- tsnames
        
        i = i +1
        incProgress(1/7, detail = paste("Processing Data", i))

        dfm <- data.frame(Date=index(MSFT),Ticker="MSFT",coredata(MSFT))
        names(dfm) <- tsnames

        i = i +1
        incProgress(1/7, detail = paste("Processing Data", i))

        dfo <- data.frame(Date=index(ORCL),Ticker="ORCL",coredata(ORCL))
        names(dfo) <- tsnames
       
        dfs <- rbind(dfa,dfg,dfi,dfb,dfm,dfo)

    })
    # Timeseries Plot for selected stocks and SP500 
    output$distPlot <- renderPlotly({
        withProgress(message = 'Generating Plot', value = 0, {
            
            p <- dfs %>% plot_ly(type = 'scatter', mode = 'lines') %>%
                add_trace(x=~Date, y=~Close, name=input$tickerInput1,
                          line=list(color="green"),
                          transforms = list(
                              list(
                                  type = 'filter',
                                  target = ~Ticker,
                                  operation = '=',
                                  value = input$tickerInput1))) %>%
                add_trace(x=~Date, y=~Close, name=input$tickerInput2,
                          line=list(color="lightblue"),
                          transforms = list(
                              list(
                                  type = 'filter',
                                  target = ~Ticker,
                                  operation = '=',
                                  value = input$tickerInput2))) %>%
                add_trace(x=~Date, y=~Close, name="SP500",yaxis = "y2",
                          line=list(color="lightgreen"),
                          transforms = list(
                              list(
                                  type = 'filter',
                                  target = ~Ticker,
                                  operation = '=',
                                  value = "SP500"))) %>%
                layout(title = "Closing Market Prices",
                   xaxis = list(title = "Dates", domain = c(0, 0.98)),
                   yaxis = list(title = "Stock Price ($US)"),
                   yaxis2 = list(title = "SP500", side = "right", overlaying = "y"))
            p
            
        })
    })
    
    # Table 1 - Profit/Loss for period
    output$table <- shiny::renderDataTable({
        tic <- c(input$tickerInput1,input$tickerInput2,"SP500")
        wdfs <- dfs[dfs$Date >=input$dateRange1[1]& dfs$Date <=input$dateRange1[2],]
        
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
        dfs[dfs$Date >=input$dateRange2[1] & dfs$Date <=input$dateRange2[2] & dfs$Ticker %in% c(input$tickerInput1,input$tickerInput2,"SP500"),]
    })
})
)
