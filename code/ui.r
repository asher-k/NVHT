library(shiny)  
library(shinydashboard)
library(networkD3)

# Define the UI used in the app
ui <- dashboardPage(skin="black",
  dashboardHeader(title = "Co-occurences of Toponyms in Hittite Texts", titleWidth = 450),
  sidebar <- dashboardSidebar(
        div(h2("About"),
            p("This page presents a network view of the co-occurences of toponyms (place names) in Hittite documents. 
               The Toponym data is sourced from the Hittite Toponym (HiTop) platform and used for purely educational purposes. Toponyms are segregated into four categories,"), 
            HTML("<ul><li><b>Choronyms</b>: proper names of regions, countries or cities.</li>
                 <li><b>Hydronyms</b>: names of bodies of water.</li>
                 <li><b>Oronyms</b>: names of hills or mountains.</li>
                 <li><b>Oikonyms</b>: names of homes, towns, or other inhabited places.</li></ul>"),
            style = "padding:10px; text-align: justify;"),
        hr(),
        sliderInput("tab_entries", "# of Table Entries in Tooltip:", min = 5, max = 15, value = 10),
        sliderInput("min_occs", "Req. # of Document Occurences:", min = 1, max = 20, value = 10),
        checkboxInput("isolates","Hide Isolated Toponyms", FALSE),
        hr(),
        div(HTML("Data sourced from HiTop<a href='https://www.hethport.uni-wuerzburg.de/HiTop/hetgeointro.php'><img style= 'display:inline-block; height:12px; width:12px;' src='https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/OOjs_UI_icon_link-ltr-invert_slanted.svg/640px-OOjs_UI_icon_link-ltr-invert_slanted.svg.png'></a>. 
                 All rights and credit to the owners and maintainers of the platform. 
                 <br>Dashboard by Asher Stout<a href='https://github.com/asher-k'><img style= 'display:inline-block; height:12px; width:12px;' src='https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/OOjs_UI_icon_link-ltr-invert_slanted.svg/640px-OOjs_UI_icon_link-ltr-invert_slanted.svg.png'></a>"), style = "padding:10px")
  ),
  body <- dashboardBody(tags$style(type = "text/css", "#Network {height: calc(100vh - 5px) !important;}"),
                        tags$style(HTML("#sidebarItemExpanded > ul > :last-child {position: absolute;bottom: 0;width: 100%;}")),
          fillPage(forceNetworkOutput("Network")) ),
  dashboardPage(dashboardHeader(title="Title"), sidebar,body)
)

