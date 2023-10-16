library(shiny)  
library(shinydashboard)
library(networkD3)

# Define the UI used in the app
ui <- dashboardPage(skin="black",
  dashboardHeader(title = "Co-occurences of Toponyms in Hittite Texts", titleWidth = 450),
  sidebar <- dashboardSidebar(
        div(h2("About"),
            p("This page presents a network view of the co-occurences of toponyms (place names) in Hittite documents."), style = "padding:10px; text-align: justify;"),
        hr(),
        sliderInput("tab_entries", "# of Table Entries in Tooltip:", min = 5, max = 15, value = 10),
        sliderInput("min_occs", "Req. # of Document Occurences:", min = 1, max = 20, value = 10),
        checkboxInput("isolates","Hide Isolated Toponyms", FALSE),
        hr(),
        div(p("Credit"), style = "padding:10px")
  ),
  body <- dashboardBody(tags$style(type = "text/css", "#Network {height: calc(100vh - 5px) !important;}"),
                        tags$style(HTML("#sidebarItemExpanded > ul > :last-child {position: absolute;bottom: 0;width: 100%;}")),
          fillPage(forceNetworkOutput("Network")) ),
  dashboardPage(dashboardHeader(title="Title"), sidebar,body)
)
