library(leaflet)
library(shinydashboard)

dashboardPage(
  dashboardHeader(
    # disable = TRUE
    title = "Open cinema Russia",
    dropdownMenu(
      type = "notifications",
      icon = icon("question-circle"),
      badgeStatus = NULL,
      headerText = "See also:",
      notificationItem("shiny", icon = icon("file"),
                       href = "http://shiny.rstudio.com/"),
      notificationItem("shinydashboard", icon = icon("file"),
                       href = "https://rstudio.github.io/shinydashboard/")
    ),
    tags$li("My header", class = "dropdown")
  ),
  dashboardSidebar(
    # actionButton("show", "Login"),
    # verbatimTextOutput("dataInfo"),
    #disable = TRUE
    collapsed = TRUE, #, width="100%"
    sidebarMenu(
      menuItem("Map", tabName = "map_view", icon = icon("globe")),
      menuItem("Table city", tabName = "table_city", icon = icon("table"))
    )
  ),
  dashboardBody(
    fluidRow(
      tabItems(
        tabItem(
          tabName = "map_view",
          #absolutePanel(),
          # fluidRow(
          # tabBox(
          div(class="outer",   
            tags$head(
              # Include our custom CSS
              includeCSS("styles.css"),
              includeScript("gomap.js")
            ),
            leafletOutput("map", width="100%", height="100%"),
            absolutePanel(
              id = "controls", class = "panel panel-default", fixed = TRUE,
              draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
              width = 330, height = "auto",
              textInput("dynamic_value","Введите город","Россия"),
              #h2("Cinema explorer"),
              #uiOutput("ui"),
              #verbatimTextOutput("dynamic_value"),
              #textInput("dynamic_value","","Россия"),
              uiOutput("ui1")
            )
          )
        ),
        tabItem(
          tabName = "table_city",
          DT::dataTableOutput("table")
        )
      )
    )
  )
)
# conditionalPanel("false", icon("crosshair"))
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
#)
# ))