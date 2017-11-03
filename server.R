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
obs1 <<- NULL

#login <- gs_title("user_data")
#login_data <- gs_read(login)
my_username <- login_data$User
my_password <- login_data$Pass

#gap <- gs_title("Input_data")
#data <- gs_read(gap)
data_new <- data
clear_data  <- data_new[complete.cases(data_new$Screen), ]

#pop <- gs_title("City_population")
#data_pop <- gs_read(pop)


#data_city <- gs_title("map_coordinates")
#city_location <- gs_read(data_city)
city_location_small <- city_location[,c(4,2,9,44,45)]
city_location_small$LAT <- gsub(',', '.', city_location_small$LAT)
city_location_small$LONG <- gsub(',', '.', city_location_small$LONG)
city_location_small$LAT <- as.double(city_location_small$LAT)
city_location_small$LONG <- as.double(city_location_small$LONG)



function(input, output, session) {

  output$ui <- renderUI({
    if (is.null(input$select))
      return()
    switch(
      input$select,
      "City" = textInput(
        "dynamic",
        "Введите город",
        value = "Россия"
      ),
      "Name" = textInput(
        "dynamic",
        "Введите название кинотеатра",
        value = "Победа"
      )
    )
  })
  
  # MaxScreen <- reactive({
  #   max(clear_data$Screen)
  # })
  # 
  # MinScreen <- reactive({
  #   min(clear_data$Screen)
  # })
  
  # output$ui1 <- renderUI({
  #   sliderInput(
  #     "range", "Залы кинотеатров",
  #     min = min(clear_data$Screen), max = max(clear_data$Screen), step = 1,
  #     value = c(min(clear_data$Screen), max(clear_data$Screen))
  #   )
  # })

  #---------------\
  # Create the map )
  #_______________/
  
  filteredData <- reactive({
    data_new[data_new$Screen >= input$range[1] & data_new$Screen  <= input$range[2],]
  })
  translite_cinema <- reactive({ 
    
    data_new$Circuit <- lapply(data_new$Circuit, as.character)
    data_new$Circuit[is.na(data_new$Circuit)] <- " "
    translite_cinema <- paste(
    sep = c("<center/>", "<br/>"),
    data_new$Name,
    data_new$Circuit,
    data_new$Screen
  )
    })
  
  translite_cinema1 <- reactive({
    
  translite_cinema1 <- paste(
    sep = c("<center/>", "<br/>"),
    city_location_small$City,
    city_location_small$Region,
    city_location_small$Pop_2016)
  })

  output$map <- renderLeaflet({
    if (input$dynamic_value == "Россия") {
      ZOOM <- 3
      LAT <- 50
      LONG <- 100
    } else {
      target_pos <- google_geocode(address = input$dynamic_value, key = key)
      LAT <- target_pos$results$geometry$location$lat
      LONG <- target_pos$results$geometry$location$lng
      ZOOM <<- 12
    }
    leaflet(
      data_new, options = leafletOptions(
        minZoom = 3, center = c(50, 100), # preferCanvas = TRUE,
        maxBounds = list(list(20, -10), list(80, 200))
      )
    ) %>%
    addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png") %>%
    
     setView(lng = LONG, lat = LAT, zoom = ZOOM ) 
    # %>%
    # addMarkers(
    #   clusterOptions = markerClusterOptions(),
    #   popup = translite_cinema()
    #)
  })
  
  
  observe({
    proxy <- leafletProxy("map",data = filteredData())
      proxy %>% clearMarkers
    if (input$legend_cinema){
      proxy %>% addMarkers(
        clusterOptions = markerClusterOptions(),
        popup = translite_cinema()
        #layerId = cinema_map
        )
    }
      
  })
  
  
  
  observe({
    proxy <- leafletProxy("map", data = city_location_small)
    proxy %>% clearMarkers
    if (input$legend_city){
      proxy %>% addMarkers(
        clusterOptions = markerClusterOptions(),
        popup = translite_cinema1()
        #layerId = city_map 
        )
    }
  })
  
  observe({
    proxy <- leafletProxy("map", data = city_location_small)
    proxy %>% clearMarkers
    if (input$legend_city == FALSE){
      # proxy %>% removeMarker(1)
    }
  })
  
  observe({
    proxy <- leafletProxy("map",data = filteredData())
    proxy %>% clearMarkers
    if (input$legend_cinema == FALSE){
      proxy %>% clearMarkers
    }
  })
  # output$map_city <- renderLeaflet({
  #   city_location_small$City <- lapply(city_location_small$City, as.character)
  #   city_location_small <-na.omit(city_location_small)
  #   #city_location_small$Pop_2016  <- city_location_small$Pop_2016[complete.cases(city_location_small$Pop_2016), ]
  #   #data_new$Circuit[is.na(data_new$Circuit)] <- " "
  #   translite_cinema1 <- paste(
  #     sep = c("<center/>", "<br/>"),
  #     city_location_small$City,
  #     city_location_small$Region,
  #     city_location_small$Pop_2016)
  # 
  #   leaflet(
  #     city_location_small, options = leafletOptions(
  #       # minZoom = 3, center = c(50, 100), # preferCanvas = TRUE,
  #       # maxBounds = list(list(20, -10), list(80, 200))
  #     )
  #   ) %>%
  #     addTiles(urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png") %>%
  #     setView(lng = city_location_small$LONG, lat = city_location_small$LAT, zoom = 3) %>%
  #     addMarkers(
  #       clusterOptions = markerClusterOptions(),
  #       popup = translite_cinema1
  #     )
  # })

  output$dynamic_value <- renderPrint({
    input$dynamic
  })
  output$table <- DT::renderDataTable(
    # data_pop,
    #data_new,
    filteredData(),
    options = list(orderClasses = TRUE, pageLength = 100, escape = FALSE)
  )


  #-----------------\
  # AUTHentification )
  #_________________/

  values <- reactiveValues(authenticated = FALSE)

  # Return the UI for a modal dialog with data selection input. If 'failed'
  # is TRUE, then display a message that the previous value was invalid.
  dataModal <- function(failed = FALSE) {
    modalDialog(
      title = "Authentification",
      textInput("username", "Username:"),
      passwordInput("password", "Password:"),
      easyClose = TRUE,
      footer = tagList(
        modalButton("Cancel"),
        actionButton("ok", "Login")
      )
    )
  }

  # Show modal when button is clicked.
  # This `observe` is suspended only whith right user credential
  o <- observeEvent(input$show, {
    if (values$authenticated) {
      values$authenticated <- FALSE
      updateActionButton(session, "show", label = "Login")
    } else {
      obs1 <<- observe({
        showModal(dataModal())
      })
    }
    output$menu <- renderMenu({
      if (values$authenticated) {
        return(
          sidebarMenu(
            menuItem("new deistvija admin", tabName = "new", icon = icon("calendar"))
          )
        )
      } else {
        return(
          sidebarMenu()
        )
      }
    })
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
        values$authenticated <- TRUE
        updateActionButton(session, "show", label = "UNLogin")
        cat("Showing", input$x, "rows\n")
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