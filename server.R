library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(readxl)
library(googlesheets)
library(ggmap)


gap <- gs_title("Input_data")
data <- gs_read(gap)
data_new <- data
#write.table(data,'out_data.csv',sep = ";")
#bob[] <- lapply(bob, as.character)
# data$Circuit <-lapply(data$Circuit,as.character)
# data$Circuit[is.na(data$Circuit)] <- ' '
# translite_cinema <- paste(sep = "<br/>",
#                           data$Name,
#                           data$Circuit,
#                           data$Booker,
#                           data$Screen)
#paste(data$Name," " ,data$Circuit," " ,data$Booker, " ", data$Screen)
# input_data <- function(num){
#   
#   switch( num,
#           read_excel("cinemas.xlsx"),
#           read_excel("cinemas_all_info.xls")
#   )
# }

function(input, output, session) {
  
  output$ui <- renderUI({
    if (is.null(input$select))
      return()
  lvl_book <- levels(data$Booker)
  switch(input$select,
    "City" = textInput("dynamic", "Введите город",
                       value = "Россия"),
    "Name" = textInput("dynamic", "Введите название кинотеатра",
                       value = "Победа")
    
  )

  
    })
  output$ui1 <- renderUI({
    data_new <- data 
    clear_data  <- data_new[complete.cases(data_new$Screen),]
  mz <- clear_data$Screen
  
  min_zal <- min(mz)
  max_zal <- max(mz)
    
  sliderInput("range", "Залы кинотеатров",
              min =min_zal , max = max_zal,step = 1,
              value = c(min_zal,max_zal))
})
# Create the map
  output$map <- renderLeaflet({
    
    data_new$Circuit <-lapply(data_new$Circuit,as.character)
    data_new$Circuit[is.na(data_new$Circuit)] <- ' '
    translite_cinema <- paste(sep = c("<center/>","<br/>"),
                              data_new$Name,
                              data_new$Circuit,
                              data_new$Screen)
    if(input$dynamic_value == "Россия" )
    {    
      ZOOM=3
      LAT=50
      LONG=100
      }else{
        target_pos=geocode(input$dynamic_value)
        LAT=target_pos$lat
        LONG=target_pos$lon
        ZOOM=8
    }
    

    leaflet(data) %>%
      #addProviderTiles(providers$OpenStreetMap.Mapnik) %>%

      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png"
      )%>%
        setView(lng=LONG, lat=LAT, zoom=ZOOM )%>%
    addMarkers(clusterOptions = markerClusterOptions(),popup = translite_cinema)
    
  })
  
  # leafletProxy("map", data = data_new) %>%
  #   clearShapes() %>%
  #   addCircles(~longitude, ~latitude, radius=radius, layerId=~zipcode,
  #              stroke=FALSE, fillOpacity=0.4, fillColor=pal(colorData)) %>%
  #   addLegend("bottomleft", pal=pal, values=colorData, title=colorBy,
  #             layerId="colorLegend")
  
  output$dynamic_value <- renderPrint({
    input$dynamic
  })
  output$table <- DT::renderDataTable(data_new,
                                      options = list(orderClasses = TRUE, pageLength = 100))
}
# Search <- "Шатров Никита"
# 
# data[which(data$Booker == Search),  ]




