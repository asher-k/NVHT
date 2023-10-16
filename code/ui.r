library(shiny)  
library(shinydashboard)
library(networkD3)

# Define the UI used in the app
ui <- dashboardPage(skin="black",
  dashboardHeader(title = "Co-occurences of Toponyms in Hittite Texts", titleWidth = 450),
  sidebar <- dashboardSidebar(
        div(h1("About"),
            p("Intro here"), style = "padding:10px"),
        hr(),
        sliderInput("tab_entries", "# of Table Entries in Tooltip:", min = 5, max = 25, value = 5),
        sliderInput("min_occs", "Req. # of Occurences in Docs:", min = 0, max = 20, value = 0),
        checkboxInput("isolates","Hide Isolated Toponyms", FALSE),
        hr(),
        div(p("Credit"), style = "padding:10px")
  ),
  body <- dashboardBody(tags$style(type = "text/css", "#Network {height: calc(100vh - 5px) !important;}"),
                        tags$style(HTML("#sidebarItemExpanded > ul > :last-child {position: absolute;bottom: 0;width: 100%;}")),
          fillPage(forceNetworkOutput("Network")) ),
  dashboardPage(dashboardHeader(title="Title"), sidebar,body)
)
