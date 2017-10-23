library(leaflet)
library(shinydashboard)

dashboardPage(
  dashboardHeader(title = "Open cinema Russia"),
  dashboardSidebar(
    disable = TRUE
    #menuItem("Add cinemas", tabName = "new_cinema", icon = icon("dashboard")),
    #menuItem("Map", tabName = "map_view", icon = icon("th"))
  ),
  dashboardBody(
    # tabItems(
    #   tabItem(tabName = "map_view",
    #absolutePanel(),

        fluidRow(
          tabBox(
            tabPanel("Tab1",
               div(class="outer",

                   tags$head(
                     # Include our custom CSS
                     includeCSS("styles.css"),
                     includeScript("gomap.js")
                   ),

                   leafletOutput("map", width="100%", height="100%"),
                   absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                 draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                 width = 330, height = "auto",
                                 textInput("dynamic_value","Введите город","Россия"),
                          
                          #uiOutput("ui"),
                          #verbatimTextOutput("dynamic_value"),
                          #textInput("dynamic_value","","Россия"),
                          uiOutput("ui1")
                          
                   ))

      ),
      tabPanel("Tab2","Tab content 2")
      
      )
      # ))
      
      
      # ,
      # 
      #   tabItem(tabName = "new_cinema",
      #           fluidRow(
      # 
      #             box(
      #               title = "Введите файл с кинотеатрами", 
      #               status = "primary", solidHeader = TRUE, width = 2,
      #               collapsible = TRUE,
      #               fileInput('file1', 'Выберите файл с кинотеатрами форматами *.xls или *xlsx',
      #                         accept = c(".xlsx",".xls")
      #               ),
      #               downloadButton("Examle", "Скачать пример файла")
      #             ),
      #             box(
      #               solidHeader = TRUE,
      #               width = 10,
      #               DT::dataTableOutput('table'))
      # 
      # ))
  )
))