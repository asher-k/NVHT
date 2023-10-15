library(shiny)  
library(shinydashboard)
library(networkD3)

# Define the UI used in the app
ui <- dashboardPage(skin="black",
  dashboardHeader(title = "Co-occurences of Toponyms in Hittite Texts", titleWidth = 450),
  sidebar <- dashboardSidebar(),
  body <- dashboardBody(  tags$style(type = "text/css", "#Network {height: calc(100vh - 5px) !important;}"),
          fillPage(forceNetworkOutput("Network")) ),
  dashboardPage(dashboardHeader(title="Title"), sidebar,body)
)
