library(shiny)
library(shinydashboard)
library(DT)
library(readr)
library(shinyWidgets)
library(magrittr)
library(tidyverse)
library(sf)
library(leaflet)
library(readr)
library(sf)
census_tracts_virginia_2000_2016 <- read_csv("~/git/dspg2020Richmond/data/census_tracts_virginia_2000-2016.csv")
eviction_rate_richmond <- census_tracts_virginia_2000_2016 %>% filter(`parent-location` == "Richmond city, Virginia")

Richmond_housing_geo<-readRDS("Richmond_housing_geo")
VAcounties<-readRDS("VAcounties")


Richmond_housing_geo$GEOID <- as.double(Richmond_housing_geo$GEOID)
Richmond_geom <- Richmond_housing_geo %>% select(GEOID, geometry)
eviction_rate_richmond <- eviction_rate_richmond %>% left_join(unique(Richmond_geom), by = "GEOID") %>% st_as_sf()

max_eviction = max(eviction_rate_richmond$`eviction-rate`, na.rm = TRUE)


sidebar <- dashboardSidebar(
  sliderInput("year", "Select year",min = 2000,max = 2016,step = 1,value = 2016,animate = T)
)

body <- dashboardBody(
  leafletOutput("myplot")
)

ui <- dashboardPage(
  dashboardHeader(title = "Richmond Eviction Rate"),
  sidebar = sidebar,
  body = body
)

server <- function(input, output, session) {

  output$myplot <- renderLeaflet({

    #set palette
    eviction_rate_year <- eviction_rate_richmond %>% filter(year == input$year)
    #mypalette <- colorQuantile(palette="viridis", Richmond_housing_geo$Median_Home_Value[Richmond_housing_geo$year==input$year],n=10)

    mypalette <- colorQuantile(palette="viridis", c(0,max_eviction),n=12)

    #construct map
    leaflet() %>%
      addTiles() %>%
      addPolygons(data=eviction_rate_year,color = ~mypalette(eviction_rate_year$`eviction-rate`),
                  smoothFactor = 0.2, fillOpacity=0.6, weight = 1,stroke = F, label=paste("Tract: ",eviction_rate_year$name, ", Value: ",eviction_rate_year$`eviction-rate`))%>%
      addLegend(pal=mypalette,position = "topright",values = c(0,max_eviction),
                labFormat = function(type, cuts, p) {
                  n = length(cuts)
                  paste0(cuts[-n], " &ndash; ", cuts[-1])},opacity = 1) %>%
      addPolylines(data = VAcounties, color = "black", opacity = 0.5, weight = 1)

  })


}

shinyApp(ui, server)

