library(shiny) 
library(networkD3)

# Back-end functionality of the app. First run required scripts to load/preprocess data and visuals
source("data.R",local = TRUE)
source("widget.R",local = TRUE)
source("viz.R",local = TRUE)

# Then define functionality
server <- function(input, output) {
    # Rendered Network
    output$Network <- renderForceNetwork({
      # Session data, keeping original data intact
      updated_rcs <- rcs
      updated_ecs <- ecs
      
      # Reactive data selection
      trs <- input$tab_entries  # update number of entries in a table
      if(input$min_occs != 1){  # remove undermentioned docs if enabled
        list[updated_rcs, updated_ecs] <- remove_size(updated_rcs, updated_ecs, input$min_occs)
      }
      if(input$isolates){  # remove isolates if enabled
        list[updated_rcs, updated_ecs] <- remove_isolates(updated_rcs, updated_ecs)
      }

      n <- forceNetwork(Links=updated_rcs, Source="From", Target="To", Value="total_count", 
        Nodes=updated_ecs, NodeID="Toponym", Group="Type", Nodesize="Freq",
        colourScale = ColourScale, linkDistance = 200, charge = -100, zoom=T,
        fontSize = 20, fontFamily = "serif", linkColour = "#666", opacity=1.0, opacityNoHover = TRUE, legend=T)
      
      # Linkages to tooltip
      n$x$options$TableRows = trs
      n <- htmlwidgets::onRender(n, tooltip)
    })
}