library(igraph)
library(networkD3)
library(scales)
library(stringi)
library(plyr)

# First reformat Toponym counts
ecs <- entry_counts 
ecs$Type <- gsub(".+:", "", ecs$Toponym)
ecs$Type <- mapvalues(ecs$Type, c("cho", "hyd", "oro"), c("Choronym", "Hydronym", "Oronym"))
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
rcs$To <- as.array(lapply(rcs$To, update_func))
rcs$From <- as.array(lapply(rcs$From, update_func))

# Rescale frequency counts for entries/relationships to scale better with the figure (optional)
ecs$Toponym <- gsub(":[a-zA-Z]*", "", ecs$Toponym)  # remove :cat from Toponyms
# rcs$total_count <- rescale(rcs$total_count, t=c(1,5))
# ecs$Freq <- rescale(ecs$Freq, t=c(1,5))

# Define the network graph
ColourScale <- 'd3.scaleOrdinal().domain(["Choronym", "Hydronym", "Oronym"]).range(["#cc189f", "#2566e8", "#db8851"]);'

n <- forceNetwork(Links=rcs, Source="From", Target="To", Value="total_count", 
             Nodes=ecs, NodeID="Toponym", Group="Type", Nodesize="Freq",
             colourScale = ColourScale, linkDistance = 80, charge = -20, zoom=T,
             fontSize = 20, fontFamily = "serif", linkColour = "#666", opacity=0.9, opacityNoHover = TRUE, legend=T
)

# Widget to make interaction with graph smoother. Shoutout to all the JS gurus on StackOverflow & other blogging sites
n <- htmlwidgets::onRender(n, jsCode =
  'function(el, x) {
    // Additional default settings
    d3.selectAll(".node text").style("font-weight", "bold");
    d3.selectAll(".node text").style("stroke", "black");
    d3.selectAll(".node text").attr("stroke-width", "0");
    d3.selectAll(".link").style("opacity", "0.2");
    
    // Moving onto/off Nodes 
    d3.selectAll(".node").on("mouseenter", function(e, d){
      d3.selectAll(".node text").style("font-size", "20");
      d3.selectAll(".node text").style("stroke-width", "0");
      d3.select(this).select("text").style("font-size", "36");
      d3.select(this).select("text").style("stroke-width", "2");
      
      // Update tooltip
      d3.select("#tooltip").style("left", d3.event.pageX - 60 + "px").style("top", d3.event.pageY + 20 + "px");
      d3.select("#tooltip").style("opacity", 1).text(d);
    });
    d3.selectAll(".node").on("mouseleave", function(e, d){
      d3.selectAll(".node text").style("stroke-width", "0");
      d3.selectAll(".node text").style("font-size", "20");
      d3.selectAll(".link").style("opacity", "0.2");
      
      // Update tooltip
      d3.select("#tooltip").style("opacity", 0);
    });
    d3.selectAll(".node").on("mousemove", function() {
      d3.select("#tooltip").style("left", d3.event.pageX - 60 + "px").style("top", d3.event.pageY + 20 + "px");
    })
    
    // Moving onto/off Linkages 
    d3.selectAll(".link").on("mouseenter", function(e, d){
      d3.select(this).style("opacity", "0.9");
      
      // Update tooltip
      d3.select("#tooltip").style("left", d3.event.pageX - 60 + "px").style("top", d3.event.pageY + 20 + "px");
      d3.select("#tooltip").style("opacity", 1).text(d);
    });
    d3.selectAll(".link").on("mouseleave", function(e, d){
      d3.select(this).style("opacity", "0.2");
      
      // Update tooltip
      d3.select("#tooltip").style("opacity", 0);
    });
    d3.selectAll(".link").on("mousemove", function() {
      d3.select("#tooltip").style("left", d3.event.pageX - 60 + "px").style("top", d3.event.pageY + 20 + "px");
    })
    
    // Setup Hover Tooltip
    d3.select("body").append("div").attr("id", "tooltip").attr("style", "position: absolute; opacity: 0;");
  }'
)

# Finally, display the visualization
n