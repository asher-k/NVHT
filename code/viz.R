library(igraph)
library(networkD3)
library(scales)
library(stringi)
library(plyr)

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
rcs$To <- as.array(lapply(rcs$To, update_func))
rcs$From <- as.array(lapply(rcs$From, update_func))

# Rescale frequency counts for entries/relationships to scale better with the figure (optional)
ecs$Toponym <- gsub(":[a-zA-Z]*", "", ecs$Toponym)  # remove :cat from Toponyms
# rcs$total_count <- rescale(rcs$total_count, t=c(1,5))
# ecs$Freq <- rescale(ecs$Freq, t=c(1,5))

# Define the network graph
ColourScale <- 'd3.scaleOrdinal().domain(["Choronym", "Hydronym", "Oronym", "Oikonym"]).range(["#f2428f", "#41a7e2", "#9e7955", "#bcb6d9"]);'

n <- forceNetwork(Links=rcs, Source="From", Target="To", Value="total_count", 
             Nodes=ecs, NodeID="Toponym", Group="Type", Nodesize="Freq",
             colourScale = ColourScale, linkDistance = 200, charge = -100, zoom=T,
             fontSize = 20, fontFamily = "serif", linkColour = "#666", opacity=1.0, opacityNoHover = TRUE, legend=T
)

# Widget to make interaction with graph smoother. Shoutout to all the JS gurus on StackOverflow & other blogging sites, y'all are doing god's work.
n <- htmlwidgets::onRender(n, jsCode =
  'function(el, x) {
    // display constants
    link_opacity_default = "0.075";
    link_opacity_select = "0.9";
    node_tooltip_html = ["<center><p margin-bottom:1px;><span style=\'font-size: 24px;\'>", 
                         "</span><br><span style=\'font-size: 12px;\'>", 
                         "</span><hr><span style=\'font-size: 14px;\'> In ", 
                         " documents</span><hr>Links to</p></center>"]
    link_tooltip_html = ["<center><p margin-bottom:1px;><span style=\'font-size: 18px;\'>", 
                         "&#8594;", 
                         "</span><br>", 
                         " documents</p></center>"]
  
    // Additional default settings
    d3.selectAll(".node text").style("stroke", "black");
    d3.selectAll(".node text").attr("stroke-width", "0");
    d3.selectAll(".node").select("circle").style("opacity", "0.475");
    d3.selectAll(".node").select("text").style("opacity", "0.8");
    d3.selectAll(".link").style("opacity", link_opacity_default);
    
    // Setup Hover Tooltip
    d3.select("body").append("div").attr("id", "tooltip")
                                   .style("position", "absolute")
                                   .style("opacity", "0")
                                   .style("background-color", "white")
                                   .style("border", "solid")
                                   .style("border-width", "1px")
                                   .style("border-radius", "5px")
                                   .style("padding", "5px")
                                   .style("margin", "0px");
    // Moving ONTO Node 
    d3.selectAll(".node").on("mouseenter", function(e, d){
      d3.selectAll(".node text").style("font-size", "20");
      d3.selectAll(".node text").style("stroke-width", "0");
      d3.select(this).select("text").style("font-size", "36");
      d3.select(this).select("text").style("stroke-width", "2");
      d3.select(this).select("text").style("opacity", "1.0");      
      d3.select(this).select("circle").style("opacity", "0.75");
      
      // Show tooltip & update text
      d3.select("#tooltip").style("left", d3.event.pageX - 60 + "px").style("top", d3.event.pageY + 20 + "px");
      d3.select("#tooltip").style("opacity", 1); 
      d3.select("#tooltip").html(node_tooltip_html[0] + x.nodes.name[d] + node_tooltip_html[1] + x.nodes.group[d]  + node_tooltip_html[2] + x.nodes.nodesize[d] + node_tooltip_html[3]);
    });
    
    // Moving OFF Node 
    d3.selectAll(".node").on("mouseleave", function(e, d){
      d3.selectAll(".node text").style("stroke-width", "0");
      d3.selectAll(".node text").style("font-size", "20");
      d3.selectAll(".node").select("circle").style("opacity", "0.475");
      d3.selectAll(".node").select("text").style("opacity", "0.8");
      d3.selectAll(".link").style("opacity", link_opacity_default);
      
      // Hide tooltip
      d3.select("#tooltip").style("opacity", 0);
    });
    
    // Moving AROUND Node 
    d3.selectAll(".node").on("mousemove", function() {
      d3.select("#tooltip").style("left", d3.event.pageX - 60 + "px").style("top", d3.event.pageY + 20 + "px");
    })
    
    // Moving ONTO Link 
    d3.selectAll(".link").on("mouseenter", function(e, d){
      d3.select(this).style("opacity", link_opacity_select);
      
      // Show tooltip & update text
      d3.select("#tooltip").style("left", d3.event.pageX - 60 + "px").style("top", d3.event.pageY + 20 + "px");
      d3.select("#tooltip").style("opacity", 1); //.text(x.nodes.name[x.links.source[d]] + "->" + x.nodes.name[x.links.target[d]] + " " + x.links.value[d]);
      d3.select("#tooltip").html(link_tooltip_html[0] + x.nodes.name[x.links.source[d]] + link_tooltip_html[1] + x.nodes.name[x.links.target[d]]  + link_tooltip_html[2] + x.links.value[d] + link_tooltip_html[3]);
    });
    
    // Moving OFF Link 
    d3.selectAll(".link").on("mouseleave", function(e, d){
      d3.select(this).style("opacity", link_opacity_default);
      
      // Hide tooltip
      d3.select("#tooltip").style("opacity", 0);
    });
    
    // Moving AROUND Link 
    d3.selectAll(".link").on("mousemove", function() {
      d3.select("#tooltip").style("left", d3.event.pageX - 60 + "px").style("top", d3.event.pageY + 20 + "px");
    })
  }'
)

# Finally, display the visualization
n