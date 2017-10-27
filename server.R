library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)
library(readxl)
library(googlesheets)
library(ggmap)

library(googleway)
key <- "AIzaSyA6s8VCdjeEWlsaQTIxGLnIjfJN9PcLKA0"

# library(rmarkdown)
# render("../dashboard.Rmd")

Logged <- FALSE
login <- gs_title("user_data")
login_data <- gs_read(login)

my_username <- login_data$User
my_password <- login_data$Pass

gap <- gs_title("Input_data")
pop <- gs_title("City_population")
data <- gs_read(gap)
data_pop <- gs_read(pop)
data_new <- data

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
      # target_pos=geocode(input$dynamic_value)
      target_pos=google_geocode(address = input$dynamic_value, key = key)
      LAT=target_pos$results$geometry$location$lat
      # LONG=target_pos$lon
      LONG=target_pos$results$geometry$location$lng
      ZOOM=12
    }
    
    
    leaflet(data) %>%
      #addProviderTiles(providers$OpenStreetMap.Mapnik) %>%
      
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png"
      )%>%
      setView(lng=LONG, lat=LAT, zoom=ZOOM )%>%
      addMarkers(clusterOptions = markerClusterOptions(),popup = translite_cinema)
      # fitBounds(lng1 = max(points$long),lat1 = max(points$lat))
    
  })
  
  output$dynamic_value <- renderPrint({
    input$dynamic
  })
  output$table <- DT::renderDataTable(data_pop,
                                      options = list(orderClasses = TRUE, pageLength = 100, escape = FALSE))
   values <- reactiveValues(authenticated = FALSE)
  
  # Return the UI for a modal dialog with data selection input. If 'failed' 
  # is TRUE, then display a message that the previous value was invalid.
  dataModal <- function(failed = FALSE) {
    modalDialog(
      textInput("username", "Username:"),
      passwordInput("password", "Password:"),
      footer = tagList(
        # modalButton("Cancel"),
        actionButton("ok", "Login")
      )
    )
  }
  
  # Show modal when button is clicked.  
  # This `observe` is suspended only whith right user credential
  
  obs1 <- observe({
    showModal(dataModal())
  })
  
  # When OK button is pressed, attempt to authenticate. If successful,
  # remove the modal. 
  
  obs2 <- observe({
    req(input$ok)
    isolate({
      Username <- input$username
      Password <- input$password
    })
    Id.username <- which(my_username == Username)
    Id.password <- which(my_password == Password)
    if (length(Id.username) > 0 & length(Id.password) > 0) {
      if (Id.username == Id.password) {
        Logged <<- TRUE
        values$authenticated <- TRUE
        obs1$suspend()
        removeModal()
        
      } else {
        values$authenticated <- FALSE
      }     
    }
  })
  
  
  output$dataInfo <- renderPrint({
    if (values$authenticated) "OK!!!!!"
    else "You are NOT authenticated"
  })
}

