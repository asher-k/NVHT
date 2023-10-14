library(igraph)
library(networkD3)
library(scales)
library(stringi)

# First reformat toponym counts
ecs <- entry_counts 
ecs$Type <- gsub(".+:", "", ecs$Toponym)
ecs$Toponym <- stri_unescape_unicode(gsub("<U\\+(....)>", "\\\\u\\1", ecs$Toponym))

# Function for assigning relationships' toponym ids instead of strings
update_func <- function(x){
  k <- which(ecs$Toponym == x)
  return(k-1)
}

# Then reformat relationships to indices of the entries
rcs <- relation_counts
rcs$To <- stri_unescape_unicode(gsub("<U\\+(....)>", "\\\\u\\1", rcs$To))
rcs$From <- stri_unescape_unicode(gsub("<U\\+(....)>", "\\\\u\\1", rcs$From))
rcs$To <- as.array(lapply(rcs$To, update_func))
rcs$From <- as.array(lapply(rcs$From, update_func))

# Rescale frequency counts for entries/relationships to scale better with the figure
ecs$Toponym <- gsub(":[a-zA-Z]*", "", ecs$Toponym)  # remove :cat from Toponyms
# rcs$total_count <- rescale(rcs$total_count, t=c(1,5))
# ecs$Freq <- rescale(ecs$Freq, t=c(1,5))

# Define the network graph
ColourScale <- 'd3.scaleOrdinal().domain(["cho", "hyd", "oro"]).range(["#cc189f", "#2566e8", "#db8851"]);'

n <- forceNetwork(Links=rcs, Source="From", Target="To", Value="total_count", 
             Nodes=ecs, NodeID="Toponym", Group="Type", Nodesize="Freq",
             colourScale = ColourScale, linkDistance = 200, charge = -30, zoom=T,
             fontSize = 20, fontFamily = "serif", linkColour = "#666", opacity=0.9, opacityNoHover = TRUE, legend=T,
)

# Widget to make interaction with graph smoother
n <- htmlwidgets::onRender(n, jsCode =
  'function(el, x) {
    d3.selectAll(".node text").style("font-weight", "bold");
    d3.selectAll(".node text").style("fill", "black")
    d3.selectAll(".link").style("opacity", "0.2");
    
    d3.selectAll(".legend text").text("Choronym");
  }'
)

# Finally, display the visualization
n