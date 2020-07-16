library(shiny)
library(shinydashboard)
library(DT)
library(readr)
library(shinyWidgets)
library(magrittr)
library(tidyverse)
library(sf)
library(leaflet)


Richmond_housing_geo<-readRDS("Richmond_housing_geo")
VAcounties<-readRDS("VAcounties")



sidebar <- dashboardSidebar(
    sliderInput("year", "Select year",min = 2010,max = 2018,step = 1,value = 2018,animate = T)
)

body <- dashboardBody(
    leafletOutput("myplot")
)

ui <- dashboardPage(
    dashboardHeader(title = "Richmond Median Home Values"),
    sidebar = sidebar,
    body = body
)

server <- function(input, output, session) {
    
    output$myplot <- renderLeaflet({
        
        #set palette
        mypalette <- colorQuantile(palette="viridis", Richmond_housing_geo$Median_Home_Value[Richmond_housing_geo$year==input$year],n=10)
        
        #construct map
        leaflet() %>%
            addTiles() %>%
            addPolygons(data=Richmond_housing_geo%>%filter(year==input$year),color = ~mypalette(Richmond_housing_geo$Median_Home_Value[Richmond_housing_geo$year==input$year]),
                        smoothFactor = 0.2, fillOpacity=0.6, weight = 1,stroke = F, label=paste("Tract: ",Richmond_housing_geo$NAME, ", Value: ",Richmond_housing_geo$Median_Home_Value[Richmond_housing_geo$year==input$year]))%>%
            addLegend(pal=mypalette,position = "topright",values = Richmond_housing_geo$Median_Home_Value[Richmond_housing_geo$year%in%input$year],
                      labFormat = function(type, cuts, p) {
                          n = length(cuts)
                          paste0(cuts[-n], " &ndash; ", cuts[-1])},opacity = 1) %>%
            addPolylines(data = VAcounties, color = "black", opacity = 0.5, weight = 1)
        
    })
    
    
}

shinyApp(ui, server)

