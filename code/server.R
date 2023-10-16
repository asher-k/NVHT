library(shiny) 
library(networkD3)

# Back-end functionality of the app. First run required scripts to load/preprocess data and visuals
source("data.R",local = TRUE)
source("widget.R",local = TRUE)
source("viz.R",local = TRUE)

# Then define functionality
server <- function(input, output) {
    output$Network <- renderForceNetwork({
      forceNetwork(Links=rcs, Source="From", Target="To", Value="total_count", 
        Nodes=ecs, NodeID="Toponym", Group="Type", Nodesize="Freq",
        colourScale = ColourScale, linkDistance = 200, charge = -100, zoom=T,
        fontSize = 20, fontFamily = "serif", linkColour = "#666", opacity=1.0, opacityNoHover = TRUE, legend=T)
      n <- htmlwidgets::onRender(n, tooltip)
    })
}