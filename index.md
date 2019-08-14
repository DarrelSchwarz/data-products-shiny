<style>
.reveal h1, .reveal h2, .reveal h3 {
  word-wrap: normal;
  -moz-hyphens: none;}
/* slide titles */
.reveal h3 {font-size: 60px; font-weight: bold; color: darkblue;}

/* heading for slides with two hashes ## */
.reveal .slides section .slideContent h2 {
   font-size: 40px; font-weight: bold; color: blue; }
   
/* ordered and unordered list styles */
.reveal ul, 
.reveal ol {font-size: 40px; color: cornflowerblue; list-style-type: square;}
.small-code pre code {
  font-size: 1em;
}
</style>
Market Data Analysis Application
========================================================
author: Darrel Schwarz
date: 12th August 2019
autosize: true
width: 1600
height: 1000

Application Link:   <https://darrelschwarz.shinyapps.io/MarketData>

github Link:    <https://github.com/DarrelSchwarz/data-products-shiny/MarketData>

<div align="center">
   <iframe src="front3.png" scrolling='no' height=900 width=1100></iframe>
</div>

Application Overview
========================================================

### The Market Data Application has three parts
- Main Panel - Timeseries Chart

>The user can select two stocks from a drop down list to compare against the SP500. It then produces a timeseries chart using 'plotly'.   

- Tab 1 - Historical Investment Comparision

>The user can enter an investment amount and a time period.
The application then works out what your profit/loss would be if you held each of the stocks for the time period.  It also shows the results for holding the SP500 so that you can compare if you were better off investing in the stock or an ETF that is tracking the SP500.

- Tab 2 - Timeseries Data

>Provides an interactive table of timeseries data for the stocks selected in the main panel, for the date period selected (defaults to 7 days).  The returned table can be searched, filtered and sorted.

Note: The market data is sourced from 'yahoo' using the 'quantmod' library.




Main Panel - Timeseries Chart
========================================================
class: small-code
<span style="font-weight:normal; color:blue;" align="left">
This code is extracted from the application and shows getting the data for the selected stocks and generating the interactive plot .
</span>

```r
# to mimic user UI inputs
input <- list(ticker1="AAPL",ticker2="GOOG")  
# Getting the data
tsnames <- c("Date","Ticker","Open","High","Low","Close","Volume","Adjusted")
getSymbols(c(input$ticker1,input$ticker2,"^GSPC"),src='yahoo',warnings=F)
dfa <- data.frame(Date=index(get(input$ticker1)), Ticker=input$ticker1, coredata(get(input$ticker1)))
dfg <- data.frame(Date=index(get(input$ticker2)), Ticker=input$ticker2, coredata(get(input$ticker2)))
dfs <- data.frame(Date=index(GSPC),Ticker="SP500",coredata(GSPC))
names(dfa)<-tsnames; names(dfg)<-tsnames; names(dfs)<-tsnames
dff <- rbind(dfa,dfg,dfs)
# Plotting the data
p <- dff %>% plot_ly(type = 'scatter', mode = 'lines') %>%
     add_trace(x=~Date, y=~Close, name=input$ticker1, line=list(color="green"), data=dff[dff$Ticker==input$ticker1,]) %>%
     add_trace(x=~Date, y=~Close, name=input$ticker2,line=list(color="lightblue"), data=dff[dff$Ticker==input$ticker2,]) %>%
     add_trace(x=~Date, y=~Close, name="SP500", yaxis = "y2", line=list(color="lightgreen"), data=dff[dff$Ticker=="SP500",]) %>%
     layout(title = "Closing Market Prices", xaxis = list(title="Dates"), yaxis = list(title="Stock Price ($US)"), 
            yaxis2 = list(title="SP500", side="right",overlaying="y"))
# Required so chart can be included in presenation
htmlwidgets::saveWidget(as_widget(p), file = "plot1.html")
```
<div align="center">
    <iframe src="plot1.html" height=750 width=1200></iframe>
<div>
Tab 1 - Historical Investment Comparison
========================================================
class: small-code
<span style="font-weight:normal; color:blue;">
This code is extracted from the application and returns the comparison table for the select stocks, date period & investment amount.
</span>


```r
# to mimic user UI inputs
input <- list(ticker1="AAPL",ticker2="GOOG",
              dateRange1=c("2007-01-01","2019-08-09"), invest=2000)
# server code
tic <- c(input$ticker1,input$ticker2,"SP500")
wdfs <- dff[dff$Date >=input$dateRange1[1] & dff$Date <=input$dateRange1[2],]

mind <- min(date(wdfs$Date)); maxd <- max(date(wdfs$Date))

wdfs2 <- wdfs[wdfs$Date %in% c(mind,maxd) & wdfs$Ticker %in% tic,]

initc <- wdfs2$Close[wdfs2$Date==mind]
finalc <- wdfs2$Close[wdfs2$Date==maxd]

initq <- trunc(input$invest/initc,0) # initial quantity
initv <- round(initq * initc,2)      # initial value
finalv <- round(initq * finalc,2)    # final value
prof <- finalv - initv               # profit
pprof <- round(finalv/initv*100,2)   # profit percentage

wrk <- as.data.frame(list(Ticker=unique(wdfs2$Ticker), Quantity=initq,
                          InitialValue=initv, CurrentValue=finalv,
                          Profit=prof, Percentage=pprof)) 
knitr::kable(wrk,format = "html",row.names=FALSE)
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> Ticker </th>
   <th style="text-align:right;"> Quantity </th>
   <th style="text-align:right;"> InitialValue </th>
   <th style="text-align:right;"> CurrentValue </th>
   <th style="text-align:right;"> Profit </th>
   <th style="text-align:right;"> Percentage </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> AAPL </td>
   <td style="text-align:right;"> 167 </td>
   <td style="text-align:right;"> 1999.23 </td>
   <td style="text-align:right;"> 33565.33 </td>
   <td style="text-align:right;"> 31566.10 </td>
   <td style="text-align:right;"> 1678.91 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GOOG </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 1863.38 </td>
   <td style="text-align:right;"> 9504.08 </td>
   <td style="text-align:right;"> 7640.70 </td>
   <td style="text-align:right;"> 510.05 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> SP500 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 1416.60 </td>
   <td style="text-align:right;"> 2918.65 </td>
   <td style="text-align:right;"> 1502.05 </td>
   <td style="text-align:right;"> 206.03 </td>
  </tr>
</tbody>
</table>

Tab 2 - Time Series Data
========================================================
class: small-code
## This code is extracted from the application and returns the time series data for the select stocks and date period  

```r
    # to mimic user UI inputs
    input <- list(ticker1="AAPL",ticker2="GOOG",
                  dateRange2=c("2019-08-05","2019-08-09"))
    # server code
    wrk <- dff[dff$Date >=input$dateRange2[1] & dff$Date <=input$dateRange2[2] &
               dff$Ticker %in% c(input$ticker1,input$ticker2,"SP500"),]
    knitr::kable(wrk,format = "html",row.names=FALSE)
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> Date </th>
   <th style="text-align:left;"> Ticker </th>
   <th style="text-align:right;"> Open </th>
   <th style="text-align:right;"> High </th>
   <th style="text-align:right;"> Low </th>
   <th style="text-align:right;"> Close </th>
   <th style="text-align:right;"> Volume </th>
   <th style="text-align:right;"> Adjusted </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 2019-08-05 </td>
   <td style="text-align:left;"> AAPL </td>
   <td style="text-align:right;"> 197.99 </td>
   <td style="text-align:right;"> 198.650 </td>
   <td style="text-align:right;"> 192.580 </td>
   <td style="text-align:right;"> 193.34 </td>
   <td style="text-align:right;"> 52393000 </td>
   <td style="text-align:right;"> 192.6082 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019-08-06 </td>
   <td style="text-align:left;"> AAPL </td>
   <td style="text-align:right;"> 196.31 </td>
   <td style="text-align:right;"> 198.070 </td>
   <td style="text-align:right;"> 194.040 </td>
   <td style="text-align:right;"> 197.00 </td>
   <td style="text-align:right;"> 35824800 </td>
   <td style="text-align:right;"> 196.2543 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019-08-07 </td>
   <td style="text-align:left;"> AAPL </td>
   <td style="text-align:right;"> 195.41 </td>
   <td style="text-align:right;"> 199.560 </td>
   <td style="text-align:right;"> 193.820 </td>
   <td style="text-align:right;"> 199.04 </td>
   <td style="text-align:right;"> 33364400 </td>
   <td style="text-align:right;"> 198.2866 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019-08-08 </td>
   <td style="text-align:left;"> AAPL </td>
   <td style="text-align:right;"> 200.20 </td>
   <td style="text-align:right;"> 203.530 </td>
   <td style="text-align:right;"> 199.390 </td>
   <td style="text-align:right;"> 203.43 </td>
   <td style="text-align:right;"> 27009500 </td>
   <td style="text-align:right;"> 202.6600 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019-08-09 </td>
   <td style="text-align:left;"> AAPL </td>
   <td style="text-align:right;"> 201.30 </td>
   <td style="text-align:right;"> 202.760 </td>
   <td style="text-align:right;"> 199.290 </td>
   <td style="text-align:right;"> 200.99 </td>
   <td style="text-align:right;"> 24619700 </td>
   <td style="text-align:right;"> 200.9900 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019-08-05 </td>
   <td style="text-align:left;"> GOOG </td>
   <td style="text-align:right;"> 1170.04 </td>
   <td style="text-align:right;"> 1175.240 </td>
   <td style="text-align:right;"> 1140.140 </td>
   <td style="text-align:right;"> 1152.32 </td>
   <td style="text-align:right;"> 2597500 </td>
   <td style="text-align:right;"> 1152.3199 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019-08-06 </td>
   <td style="text-align:left;"> GOOG </td>
   <td style="text-align:right;"> 1163.31 </td>
   <td style="text-align:right;"> 1179.960 </td>
   <td style="text-align:right;"> 1160.000 </td>
   <td style="text-align:right;"> 1169.95 </td>
   <td style="text-align:right;"> 1709400 </td>
   <td style="text-align:right;"> 1169.9500 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019-08-07 </td>
   <td style="text-align:left;"> GOOG </td>
   <td style="text-align:right;"> 1156.00 </td>
   <td style="text-align:right;"> 1178.445 </td>
   <td style="text-align:right;"> 1149.624 </td>
   <td style="text-align:right;"> 1173.99 </td>
   <td style="text-align:right;"> 1444300 </td>
   <td style="text-align:right;"> 1173.9900 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019-08-08 </td>
   <td style="text-align:left;"> GOOG </td>
   <td style="text-align:right;"> 1182.83 </td>
   <td style="text-align:right;"> 1205.010 </td>
   <td style="text-align:right;"> 1173.020 </td>
   <td style="text-align:right;"> 1204.80 </td>
   <td style="text-align:right;"> 1468000 </td>
   <td style="text-align:right;"> 1204.8000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019-08-09 </td>
   <td style="text-align:left;"> GOOG </td>
   <td style="text-align:right;"> 1197.99 </td>
   <td style="text-align:right;"> 1203.880 </td>
   <td style="text-align:right;"> 1183.603 </td>
   <td style="text-align:right;"> 1188.01 </td>
   <td style="text-align:right;"> 1065700 </td>
   <td style="text-align:right;"> 1188.0100 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019-08-05 </td>
   <td style="text-align:left;"> SP500 </td>
   <td style="text-align:right;"> 2898.07 </td>
   <td style="text-align:right;"> 2898.070 </td>
   <td style="text-align:right;"> 2822.120 </td>
   <td style="text-align:right;"> 2844.74 </td>
   <td style="text-align:right;"> 4513730000 </td>
   <td style="text-align:right;"> 2844.7400 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019-08-06 </td>
   <td style="text-align:left;"> SP500 </td>
   <td style="text-align:right;"> 2861.18 </td>
   <td style="text-align:right;"> 2884.400 </td>
   <td style="text-align:right;"> 2847.420 </td>
   <td style="text-align:right;"> 2881.77 </td>
   <td style="text-align:right;"> 4154240000 </td>
   <td style="text-align:right;"> 2881.7700 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019-08-07 </td>
   <td style="text-align:left;"> SP500 </td>
   <td style="text-align:right;"> 2858.65 </td>
   <td style="text-align:right;"> 2892.170 </td>
   <td style="text-align:right;"> 2825.710 </td>
   <td style="text-align:right;"> 2883.98 </td>
   <td style="text-align:right;"> 4491750000 </td>
   <td style="text-align:right;"> 2883.9800 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019-08-08 </td>
   <td style="text-align:left;"> SP500 </td>
   <td style="text-align:right;"> 2896.21 </td>
   <td style="text-align:right;"> 2938.720 </td>
   <td style="text-align:right;"> 2894.470 </td>
   <td style="text-align:right;"> 2938.09 </td>
   <td style="text-align:right;"> 4106370000 </td>
   <td style="text-align:right;"> 2938.0901 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2019-08-09 </td>
   <td style="text-align:left;"> SP500 </td>
   <td style="text-align:right;"> 2930.51 </td>
   <td style="text-align:right;"> 2935.750 </td>
   <td style="text-align:right;"> 2900.150 </td>
   <td style="text-align:right;"> 2918.65 </td>
   <td style="text-align:right;"> 3350640000 </td>
   <td style="text-align:right;"> 2918.6499 </td>
  </tr>
</tbody>
</table>
