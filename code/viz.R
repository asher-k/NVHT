library(igraph)
library(networkD3)
library(scales)
library(stringi)
library(plyr)
library(gsubfn)

# run locally?
local = FALSE

# First reformat Toponym counts
ecs <- entry_counts 
ecs$Type <- gsub(".+:", "", ecs$Toponym)
ecs$Type <- mapvalues(ecs$Type, c("cho", "hyd", "oro", "oik"), c("Choronym", "Hydronym", "Oronym", "Oikonym"))
ecs$Toponym <- stri_unescape_unicode(gsub("<U\\+(....)>", "\\\\u\\1", ecs$Toponym))

# Function for assigning relationships' Toponym ids instead of strings
update_func <- function(x){
  k <- which(ecs$Toponym == x)
  return(k-1)
}

# Then reformat relationships to indices of the entries
rcs <- relation_counts
rcs$To <- stri_unescape_unicode(gsub("<U\\+(....)>", "\\\\u\\1", rcs$To))
rcs$From <- stri_unescape_unicode(gsub("<U\\+(....)>", "\\\\u\\1", rcs$From))
rcs$To <- as.numeric(lapply(rcs$To, update_func))
rcs$From <- as.numeric(lapply(rcs$From, update_func))

# Rescale frequency counts for entries/relationships to scale better with the figure (optional)
ecs$Toponym <- gsub(":[a-zA-Z]*", "", ecs$Toponym)  # remove :cat from Toponyms
# rcs$total_count <- rescale(rcs$total_count, t=c(1,5))
# ecs$Freq <- rescale(ecs$Freq, t=c(1,5))

# Define the network graph
ColourScale <- 'd3.scaleOrdinal().domain(["Choronym", "Hydronym", "Oronym", "Oikonym"]).range(["#f2428f", "#41a7e2", "#9e7955", "#bcb6d9"]);'
def_table_rows <- 5
if(local){
  n <- forceNetwork(Links=rcs, Source="From", Target="To", Value="total_count", 
                    Nodes=ecs, NodeID="Toponym", Group="Type", Nodesize="Freq",
                    colourScale = ColourScale, linkDistance = 200, charge = -100, zoom=T,
                    fontSize = 20, fontFamily = "serif", linkColour = "#666", opacity=1.0, opacityNoHover = TRUE, legend=T
  )
  n$x$options <- c(n$x$options, TableRows=def_table_rows)
  n <- htmlwidgets::onRender(n, jsCode = tooltip)
  # And Display! (local only)
  n
}