library(leaflet)
library(shinydashboard)

dashboardPage(
  dashboardHeader(
    title = "Open cinema Russia",
    dropdownMenu(
      type = "notifications",
      icon = icon("question-circle"),
      badgeStatus = NULL,
      headerText = "See also:",
      tags$li(
        tags$a(
          href = "https://github.com/lolowq/test_228",
          target = "_blank", icon("github"), "github"
        )
      ),
      notificationItem(
        "docs", icon = icon("file"),
        href = "https://drive.google.com/drive/folders/0BwkvYHu15hIlb0JNV2RnbjdRb1E"
      )
    ),
    tags$li("My header", class = "dropdown")
  ),
  dashboardSidebar(
    collapsed = TRUE,
    sidebarMenu(
      menuItem("Map", tabName = "map_view", icon = icon("globe")),
      menuItem("Table city", tabName = "table_city", icon = icon("table")),
      menuItem("Authorization", tabName = "registration", icon = icon("sign-in"))
    ),
    sidebarMenuOutput("menu")
  ),
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "map_view",
        div(class = "outer",
          leafletOutput("map", width = "100%", height = "100%"),
          absolutePanel(
            id = "controls", class = "panel panel-default",
            fixed = TRUE, draggable = TRUE,
            top = 60, left = "auto", right = 20, bottom = "auto",
            width = 330, height = "auto",
            textInput("dynamic_value", "Введите город", "Россия"),
            uiOutput("ui1")
          )
        )
      ),
      tabItem(
        tabName = "table_city",
        DT::dataTableOutput("table")
      ),
      tabItem(
        class = "active",
        tabName = "registration",
        actionButton("show", "Login"),
        verbatimTextOutput("dataInfo")
      ),
      tabItem(
        tabName = "new",
        actionButton("show2", "Login2")
        # TODO : here must be ability to insert new data
      )
    ),
    tags$body(
      includeCSS("styles.css"),
      includeScript("gomap.js")
    )
  )
)