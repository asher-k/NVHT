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
    max_table_entries = 5;
    link_opacity_default = "0.075";
    link_opacity_select = "0.9";
    node_tooltip_html = ["<center><p margin-bottom:0px;><span style=\'font-size: 24px;\'>", 
                         "</span> <span style=\'font-size: 12px;\'>", 
                         "</span><hr><span style=\'font-size: 14px;\'> In ", 
                         " documents</span><br><span style=\'font-size: 14px;\'>Mentioned with</span><table>",
                         "<tr>", "<td>", "</td>", "</tr>",
                         "</table></p></center>"]
    link_tooltip_html = ["<center><p margin-bottom:1px;><span style=\'font-size: 18px;\'>", 
                         " &#8596; ", 
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
      
      // Show tooltip & update HTML with relevant data about the Toponym
      d3.select("#tooltip").style("left", d3.event.pageX + 20 + "px").style("top", d3.event.pageY + 20 + "px");
      d3.select("#tooltip").style("opacity", 1); 
      tooltip_info = node_tooltip_html[0] + x.nodes.name[d] + node_tooltip_html[1] + x.nodes.group[d]  + node_tooltip_html[2] + x.nodes.nodesize[d] + node_tooltip_html[3];
      
      // Get all links with other nodes for this node and their corresponding strengths
      var sources = x.links.source.map((p, q) => p === d ? q : "").filter(String);
      var sources_n = sources.map((p) => x.links.target[p]);
      var sources_s = sources.map((p) => x.links.value[p]);

      var targets = x.links.target.map((p, q) => p === d ? q : "").filter(String);
      var targets_n = targets.map((p) => x.links.source[p]);
      var targets_s = targets.map((p) => x.links.value[p]);
      
      nodes = sources_n.concat(targets_n);
      nodes_s = sources_s.concat(targets_s);
      var node_dict = {};
      for (let k = 0; k <nodes.length; k++){
        node_dict[nodes[k]] = nodes_s[k];
      }
      node_order = Object.values(node_dict).sort(function(a, b) {return a > b ? 1 : -1;});
      sorted = Object.entries(node_dict);
      sorted.sort((a, b) => node_order.indexOf(a[1]) - node_order.indexOf(b[1])).reverse();

      if(nodes.length < 1){
         tooltip_info += node_tooltip_html[4] + node_tooltip_html[5] + "<em>Isolate</em>" + node_tooltip_html[6] + node_tooltip_html[7];
      }
      else{
        for(let i = 0; i < Math.min(nodes.length, max_table_entries); i++){
           next_node = sorted[i];
           tooltip_info += node_tooltip_html[4] + node_tooltip_html[5] + x.nodes.name[next_node[0]] + "&nbsp;&nbsp;&nbsp;&nbsp;" + node_tooltip_html[6] + node_tooltip_html[5] + next_node[1] + node_tooltip_html[6] + node_tooltip_html[7]; // x.nodes.name[nodes[node_index]] nodes_s[node_index]
        }
        if(nodes.length > 5){
          r_conns = nodes.length-5
          tooltip_info += node_tooltip_html[4] + node_tooltip_html[5] + "and " + r_conns + " others..." + node_tooltip_html[6] + node_tooltip_html[7];
        }
      }
      tooltip_info = tooltip_info + node_tooltip_html[8];
      d3.select("#tooltip").html(tooltip_info);
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
      d3.select("#tooltip").html("");
    });
    
    // Moving AROUND Node 
    d3.selectAll(".node").on("mousemove", function() {
      d3.select("#tooltip").style("left", d3.event.pageX + 20 + "px").style("top", d3.event.pageY + 20 + "px");
    })
    
    // Moving ONTO Link 
    d3.selectAll(".link").on("mouseenter", function(e, d){
      d3.select(this).style("opacity", link_opacity_select);
      
      // Show tooltip & update text
      d3.select("#tooltip").style("left", d3.event.pageX + 20 + "px").style("top", d3.event.pageY + 20 + "px");
      d3.select("#tooltip").style("opacity", 1); //.text(x.nodes.name[x.links.source[d]] + "->" + x.nodes.name[x.links.target[d]] + " " + x.links.value[d]);
      d3.select("#tooltip").html(link_tooltip_html[0] + x.nodes.name[x.links.source[d]] + link_tooltip_html[1] + x.nodes.name[x.links.target[d]]  + link_tooltip_html[2] + x.links.value[d] + link_tooltip_html[3]);
    });
    
    // Moving OFF Link 
    d3.selectAll(".link").on("mouseleave", function(e, d){
      d3.select(this).style("opacity", link_opacity_default);
      
      // Hide tooltip
      d3.select("#tooltip").style("opacity", 0);
      d3.select("#tooltip").html("");
    });
    
    // Moving AROUND Link 
    d3.selectAll(".link").on("mousemove", function() {
      d3.select("#tooltip").style("left", d3.event.pageX + 20 + "px").style("top", d3.event.pageY + 20 + "px");
    })
  }'
)

# # And Display! (local only)
# n