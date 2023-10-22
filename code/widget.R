# Widget to make interaction with graph smoother. Shoutout to all the JS gurus on StackOverflow & other blogging sites, y'all are doing god's work.
tooltip <- 'function(el, x) {
    // display constants
    max_table_entries = x.options.TableRows;
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
        if(nodes.length > max_table_entries){
          r_conns = nodes.length-max_table_entries
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
    });
    
    // Keeping legend at the same scale irrespective of zoom/pan
    d3.select("svg").append("g").attr("id", "legend-layer");
    var legend_layer = d3.select("#legend-layer");
    d3.selectAll(".legend")
      .each(function() { legend_layer.append(() => this); });
}'

# JS pan/zoom behavior on node search
js_search <- 'shinyjs.searchNode = function(searched){
    if(searched != ""){
    
      // Setup movements to searched node 
      var svg = d3.select("svg");
      var k = svg.append("g");
      function zoomed() {
        svg.select(".zoom-layer").attr("transform", d3.event.transform);
      }
      var zoom = d3.zoom().scaleExtent([1, 8]).on("zoom", zoomed);

      //Find the node
      s_node = d3.selectAll(".node").select("circle").filter(function(d, i) { 
        n = d.name;
        return n.replace(/Ḫ/g,"H").replace(/ḫ/g, "h") == searched; 
      }).datum();
  
      // compute locations for transition & zoom
      var width = d3.select("svg").node().clientWidth / 1;
      var height = d3.select("svg").node().clientHeight / 1;
      var s_x = s_node.x, s_y = s_node.y;
      var z = 160;
      var bounds = [[s_x-z, s_y-z],[s_x+z, s_y+z]];
      
      var dx = bounds[1][0] - bounds[0][0], 
          dy = bounds[1][1] - bounds[0][1], 
          n_x = (bounds[0][0] + bounds[1][0]) / 2, 
          n_y = (bounds[0][1] + bounds[1][1]) / 2, 
          sc = Math.max(1, Math.min(8, 0.9 / Math.max(dx / width, dy / height))), 
          trs = [width / 2 - sc * n_x, height / 2 - sc * n_y];

      // d3.select("#legend-layer").append("text").text(trs).attr("x", 50).attr("y", 300);  // positional logging/sanity check
      
      // pan/zoom to location of node
      svg.transition().duration(1000).call(zoom.transform, d3.zoomIdentity.translate(trs[0], trs[1]).scale(sc));
      svg.select(".zoom-layer").attr("transform", "translate(" + trs[0] + "," + trs[1] + ")scale(" + sc + ")");
    }
}'