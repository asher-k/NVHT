library(shiny)  
library(shinyjs)
library(shinyBS)
library(shinydashboard)
library(networkD3)

# Load any necessary code
source("widget.R", local = TRUE)

link_icon = 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ef/OOjs_UI_icon_link-ltr-invert_slanted.svg/640px-OOjs_UI_icon_link-ltr-invert_slanted.svg.png'
# Define the UI used in the app
ui <- dashboardPage(
  dashboardHeader(title="Co-occurrences of Toponyms in Hittite Texts", titleWidth = 450), 
  sidebar <- dashboardSidebar(
      div(style = "padding:10px; text-align: justify;"),
      selectizeInput(
        inputId = "topsearch", 
        label = "Toponym Search",
        multiple = FALSE,
        choices = NULL,
        options = list(
          create = FALSE,
          placeholder = "Enter toponym...",
          maxItems = '1',
          onInitialize = I('function() { this.setValue(""); }'),
          onDropdownOpen = I("function($dropdown) {if (!this.lastQuery.length) {this.close(); this.settings.openOnFocus = false;}}"),
          onType = I("function (str) {if (str === \"\") {this.close();}}"))
      ),
      bsTooltip("topsearch", "Enter a toponym to zoom to its position in the network"),
      sliderInput("tab_entries", "# of Table Entries in Tooltip:", min = 5, max = 15, value = 10),
      bsTooltip("tab_entries", "Adjust the number of co-occurring toponyms displayed when hovering over a node"),
      sliderInput("min_occs", "Req. # of Document Occurences:", min = 1, max = 20, value = 10),
      bsTooltip("min_occs", "Hide documents with fewer total occurrences than this threshold"),
      checkboxInput("isolates","Hide Isolated Toponyms", FALSE),
      bsTooltip("isolates", "Hide all toponyms that do not co-occurrences with other toponyms"),
      hr(),
      div(p("This page presents a network view of the co-occurrences of toponyms (place names) in Hittite documents. 
             The Toponym data is sourced from the Hittite Toponym (HiTop) platform and used here for purely educational purposes. Toponyms are segregated into four categories,"), 
          HTML("<ul><li><b>Choronyms</b>: proper names of regions, countries or cities.</li>
               <li><b>Hydronyms</b>: names of bodies of water.</li>
               <li><b>Oronyms</b>: names of hills or mountains.</li>
               <li><b>Oikonyms</b>: names of homes, towns, or other inhabited places.</li></ul>"),
          HTML("<em><span style='font-size:9.0pt'>Please allow up to 5 seconds for the application to load filtered data. For the best user experience view in a computer-based modern browser.</span></em>"),
          style = "padding:10px; text-align: justify;"
      ),
      hr(),
      div(HTML(sprintf("Data sourced from HiTop<a href='https://www.hethport.uni-wuerzburg.de/HiTop/hetgeointro.php'><img style= 'display:inline-block; height:16px; width:16px;' src=\"%s\"></a>.<br>
                        All data rights and credit to the owners and maintainers of the platform.<br>
                        <br>Dashboard by Asher Stout<a href='https://github.com/asher-k'><img style= 'display:inline-block; height:16px; width:16px;' src=\"%s\"'></a>
                        <br>Source code available on GitHub<a href='https://github.com/asher-k/NVHT'><img style= 'display:inline-block; height:16px; width:16px;' src=\"%s\"'></a>", link_icon, link_icon, link_icon )), style = "padding:10px")
  ),
  body <- dashboardBody(useShinyjs(),
                        extendShinyjs(text = js_search, functions = c("searchNode")),
                        tags$style(type = "text/css", "#Network {height: calc(100vh - 5px) !important;}"),
                        tags$style(HTML("#sidebarItemExpanded > ul > :last-child {position: absolute;bottom: 0;width: 100%;}")),
          fillPage(forceNetworkOutput("Network")) ),
  dashboardPage(dashboardHeader(title="NVHT: Network Visualization of Hittite Toponyms"), sidebar,body),
  skin="black"
)