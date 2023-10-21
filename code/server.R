library(shiny) 
library(networkD3)
library(readr)
library(plyr)
library(gsubfn)

# Back-end functionality of the app. Load/preprocess data and tooltip
source("widget.R", local = TRUE)
ecs <- read_csv("./shiny_data/ecs.csv")
rcs <- read_csv("./shiny_data/rcs.csv")
ColourScale <- 'd3.scaleOrdinal().domain(["Choronym", "Hydronym", "Oronym", "Oikonym"]).range(["#f2428f", "#41a7e2", "#9e7955", "#bcb6d9"]);'
def_table_rows <- 5

# Helper function to reindex relationships with nodes  after some have been removed
reindex_data <- function(r, e, inv){
  old <- c(1:nrow(e))
  old <- old[-inv]-1  # old indices
  e <- e[-inv,]  # remove invalid toponyms
  new <- c(1:nrow(e)) # new indices
  rownames(e) <- new
  new <- new-1
  
  r$To <- mapvalues(r$To, old, new, warn_missing = FALSE)
  r$From <- mapvalues(r$From, old, new, FALSE)
  return(list(r, e))
}

# Function to remove isolates (Toponyms with 0 connections) from the data
remove_isolates <- function(r, e){
  indices = c(1:nrow(e))-1
  inv <- which(!(indices %in% c(r$To, r$From)))
  list[r, e] <- reindex_data(r, e, inv)
  return(list(r, e))
}

# Function to remove Toponyms under a given threshold
remove_size <- function(r, e, n){
  inv <- which(e[ , 2] < n)
  m1 <- inv-1
  r <- r[!r$To %in% m1,] 
  r <- r[!r$From %in% m1,] # remove rows with links we don't care about
  
  list[r, e] <- reindex_data(r, e, inv)
  return(list(r, e))
}

# Then define functionality
server <- function(input, output, session) {
    # Session data, keeping original data intact
    updated_rcs <- rcs
    updated_ecs <- ecs
    
    # Reactive data selection
    rds <- reactive({
      trs <- input$tab_entries # update number of entries in a table
      if(input$min_occs != 1){  # remove undermentioned docs if enabled
        list[updated_rcs, updated_ecs] <- remove_size(updated_rcs, updated_ecs, input$min_occs)
      }
      if( input$isolates ){  # remove isolates if enabled
        list[updated_rcs, updated_ecs] <- remove_isolates(updated_rcs, updated_ecs)
      }
      updateSelectInput(session = session, inputId = "topsearch", choices = updated_ecs$Toponym)
      return(list(trs, updated_rcs, updated_ecs))
    })
  
    # Rendered Network
    output$Network <- renderForceNetwork({
      # Update UI elements and selected data
      list[trs, updated_rcs, updated_ecs] <- rds()
      
      # Re-draw network
      n <- forceNetwork(Links=updated_rcs, Source="From", Target="To", Value="total_count", 
        Nodes=updated_ecs, NodeID="Toponym", Group="Type", Nodesize="Freq",
        colourScale = ColourScale, linkDistance = 200, charge = -100, zoom=T,
        fontSize = 20, fontFamily = "serif", linkColour = "#666", opacity=1.0, opacityNoHover = TRUE, legend=T)
      
      # Linkages to tooltip
      n$x$options$TableRows = trs
      n$x$options$SearchedNode = input$topsearch
      print(n$x$options$SearchedNode)

      n <- htmlwidgets::onRender(n, tooltip)
    })
}