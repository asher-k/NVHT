# Widget to make interaction with graph smoother. Shoutout to all the JS gurus on StackOverflow & other blogging sites, y'all are doing god's work.
tooltip <- 'function(el, x) {
    // display constants
    max_table_entries = x.options.TableRows;
    link_opacity_default = "0.075";
    link_opacity_select = "0.9";
    selected_item = "";
    selected_ft = "";
    selected_colour = "";
    highlight = "#FF2800";
    win_height = window.innerHeight;
    win_width = window.innerWidth;
    panel_height = Math.max(win_height*0.445, 600);
    panel_width = Math.max(win_width*0.35, 400);

    // Additional default settings
    d3.selectAll(".node text").style("stroke", "black");
    d3.selectAll(".node text").attr("stroke-width", "0");
    d3.selectAll(".node").select("circle").style("opacity", "0.475");
    d3.selectAll(".node").select("text").style("opacity", "0.8");
    d3.selectAll(".link").style("opacity", link_opacity_default);
    
    // Tooltip HTMLs
    node_tooltip_html = ["<center><p margin-bottom:0px;><span style=\'font-size: 24px;\'>", 
                         "</span> <span style=\'font-size: 12px;\'>", 
                         "</span><hr style=\'border-color: #D3D3D3\'><span style=\'font-size: 14px;\'> In ", 
                         " documents</span><br><span style=\'font-size: 14px;\'>Mentioned with</span><table>",
                         "<tr>", "<td>", "</td>", "</tr>",
                         "</table></p></center>"];
    link_tooltip_html = ["<center><p margin-bottom:1px;><span style=\'font-size: 18px;\'>", 
                         " &#8596; ", 
                         "</span><br>", 
                         " documents</p></center>"];
    
    // Info Panel for Links
    info_panel_default = ["<center><p margin-bottom:1px;><span style=\'font-size: 14px; font-style: italic;\'>", 
                         "</span><br>", 
                         "</p></center>"];
    info_panel_select = ["<center><p margin-bottom:1px;><span style=\'font-size: 24px;\'>", 
                         `</span></p><hr style=\'border-color: #D3D3D3\'><div class=panel panel-default style=\'height: ${panel_height*0.8525}px;\'><div class=panel-heading style=\'height: ${panel_height*0.1}px;\'>`, 
                         ` Shared Documents</div><div style=\'height: ${panel_height*0.75}px; overflow-y: scroll;\'>`,
                         "<table class=\'table table-striped\'><thead><tr style=\'position: sticky; top: 0px; background: #eee;\'><th>Document</th><th>CTH</th><th>Found</th><th>Date</th><th>Ref. #</th></tr></thead><tbody>",
                         "</tbody></div></div></center>"];
    
    // Info panel for Nodes (can switch between 2 tabs)
    info_panel_node = [`<style>nav > div li a.nav-item.nav-link:hover, 
                               nav > div li a.nav-item.nav-link:focus,
                               nav > div li a.nav-item.nav-link.active
                               { border: none; background: #E0E0E0; color:#000; border-radius: 7px; }
                        </style><center> <p margin-bottom:1px;> <span style=\'font-size: 24px;\'>`,
                       "</span> <span style=\'font-size: 12px;\'>", "</span> </p><hr style=\'border-color: #D3D3D3\'> </center>", 
                       `<center><div class=row row-content> <nav> <div class=col-12 id=tabs> <ul class=nav nav-tabs> <li> <a id=t1b class=\'nav-item active nav-link\' role=tab data-toggle=tab title=\'Co-occurences with other toponyms (c)\' href=#tab1 style=\'display: block;\'>Co-occurrences</a> </li> <li><a id=t2b class=\'nav-link nav-item\' role=tab data-toggle=tab title=\'Solo occurrences of this toponym (i)\' href=#tab2 style=\'display: block;\'` + ">Isolated Occurrences</a> </li> </ul> </div> </nav> </div>",
                       `<div class=panel panel-default style=\'height: ${panel_height*0.785}px; width: ${panel_width*0.98}px; border-radius: 7px;\'> <div class=tab-content>`,
                       "</div> </div> </center>"];
                       
    nodeLinkPanel = ["<div role=tabpanel class=tab-pane fade id=tab1 style=\'display:block\'>", "</div>"]
    nodeIsoPanel = ["<div role=tabpanel class=tab-pane fade id=tab2 style=\'display:none\'>", "</div>"]
    
    // Setup Hover Tooltip & Info panel styling
    d3.select("body").append("div").attr("id", "tooltip")
                                   .style("position", "absolute")
                                   .style("opacity", "0")
                                   .style("background-color", "#F1F1F1")
                                   .style("border", "solid")
                                   .style("border-color", "#D3D3D3")
                                   .style("border-width", "1px")
                                   .style("border-radius", "5px")
                                   .style("padding", "5px")
                                   .style("margin", "0px");
    d3.selectAll(".node text").attr("pointer-events", "none");
    
    
                                   
    // Keep legend at the same scale irrespective of zoom/pan
    //d3.select("svg").selectAll("g").style("pointer-events", "visiblePaint");
    d3.select("svg").append("g").attr("id", "legend-layer");
    var legend_layer = d3.select("#legend-layer");
    d3.selectAll(".legend").each(function() { legend_layer.append(() => this); });
    
    // Define initial values of Information Box in the Top Right of screen
    d3.select("svg").append("g").attr("id", "info-layer");
    var info_layer = d3.select("#info-layer").append("foreignObject");
    var init_w = win_width*0.2,
        init_h = win_height*0.04;
    info_layer.append("xhtml:div")
              .attr("id", "infobox")
              .style("position", "absolute")
              .style("opacity", "0.9")
              .style("background-color", "#F1F1F1")
              .style("border", "solid")
              .style("border-color", "#D3D3D3")
              .style("border-width", "1px")
              .style("border-radius", "5px")
              .style("pointer-events", "all")
              .style("padding", "5px")
              .style("margin", "0px");
    var infobox = d3.select("#infobox");
    infobox.on("mousedown", function(){  // allows text selection and prevents background elements from being chosen in the info box
      d3.event.stopPropagation();
    });
    infobox.on("wheel", function(d){  
      d3.event.stopPropagation();
    });
    infobox.on("dblclick", function(d){  
      d3.event.stopPropagation();
    });

    // Functions to reset the infobox to initialized values & zoom to a given node
    function reset_infobox(){
      info_layer.attr("width", init_w).attr("height", init_h).attr("y", 0).attr("x", (d3.select("svg").node().clientWidth/1)-init_w);
      infobox.style("width", init_w + "px")
             .style("height", init_h + "px")
             .html(info_panel_default[0] + "Select a Toponym or Link" + info_panel_default[1] + info_panel_default[2]);
      // remove any special colours from selected
      if(selected_item != ""){
        selected_item.style(selected_feat, selected_colour);
        selected_item = "";
        selected_colour = "";
      }
    }
    reset_infobox();

    function zoom_selected(){  // Identical functionality to searching for a node
      searched = d3.select("#locateButton").attr("data-s");
      var svg = d3.select("svg");
      var k = svg.append("g");
      function zoomed() {
        svg.select(".zoom-layer").attr("transform", d3.event.transform);
      }
      var zoom = d3.zoom().scaleExtent([1, 8]).on("zoom", zoomed);

      //Find the node
      s_node = d3.selectAll(".node").select("circle").filter(function(d, i) { 
        n = d.name;
        return n == searched; 
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

      // pan/zoom to location of node
      svg.transition().duration(1000).call(zoom.transform, d3.zoomIdentity.translate(trs[0], trs[1]).scale(sc));
      svg.select(".zoom-layer").attr("transform", "translate(" + trs[0] + "," + trs[1] + ")scale(" + sc + ")");
    }
    
    function select_isolates(){
      document.getElementById("tab1").style.display = "none"; 
      document.getElementById("tab2").style.display = "block";
      d3.select("#t2b").classed("active", true);
      d3.select("#t1b").classed("active", false);
    }
    function select_cooccurs(){
      document.getElementById("tab1").style.display = "block"; 
      document.getElementById("tab2").style.display = "none";
      d3.select("#t1b").classed("active", true);
      d3.select("#t2b").classed("active", false);
    }
    
    // Keypresses
    document.onkeydown = function(evt) {
      evt = evt || window.event;
      check = d3.select("#locateButton") !== null;
      if (evt.keyCode == 70 && check) {
          zoom_selected();
      } else if (evt.keyCode == 27){
          reset_infobox();
      } else if (evt.keyCode == 67){
          select_cooccurs();
      } else if (evt.keyCode == 73){
          select_isolates();
      }
    };
    

    // Move Info Box on window resize
    var timeOutFunctionId;
    function trnsfinf(){
      np = info_layer.attr("x");
      dp = (d3.select("svg").node().clientWidth/1)-info_layer.attr("width");
      np = dp-np;
      info_layer.attr("transform"," translate("+np+",0)");
    }
    window.addEventListener("resize", function(){
      clearTimeout(timeOutFunctionId); 
      timeOutFunctionId = setTimeout(trnsfinf, 1); 
    });

    
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
      d3.select("#tooltip").style("opacity", 0.9); 
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
           tooltip_info += node_tooltip_html[4] + node_tooltip_html[5] + x.nodes.name[next_node[0]] + "&nbsp;&nbsp;&nbsp;&nbsp;" + node_tooltip_html[6] + node_tooltip_html[5] + next_node[1] + node_tooltip_html[6] + node_tooltip_html[7];
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
    });
    
    
    
    // Moving ONTO Link 
    d3.selectAll(".link").on("mouseenter", function(e, d){
      d3.selectAll(".node").filter(function (k, i) { return i === 1;}).dispatch("mouseleave");
      d3.select(this).style("opacity", link_opacity_select);
      
      // Show tooltip & update text
      d3.select("#tooltip").style("left", d3.event.pageX + 20 + "px").style("top", d3.event.pageY + 20 + "px");
      d3.select("#tooltip").style("opacity", 0.9); 
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
    
    
    
    // Functions for adding buttons to info box
    function addQuit(){
      infobox.append("div")
             .attr("class", "lead")
             .attr("title", "Close viewer (esc)")
             .html("<button id=resetButton style=\'padding: 0; border: 0; margin : 0; position:absolute; top:0px; left:1px; width:28px; height:28px; \'><img src=\'https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/CloseWindow.svg/800px-CloseWindow.png\' style=\'width:28px; height:28px\'></button>");
      rb = document.getElementById("resetButton");
      rb.addEventListener("click", reset_infobox);
    }
    function addLoc(s){
      infobox.append("div")
             .attr("class", "lead")
             .attr("title", "Locate toponym (f)")
             .html(`<button id=locateButton data-s=\'${s}\' style=\'padding: 0; border: 0; margin : 0; position:absolute; top:0px; right:1px; width:28px; height:28px;\'><img src=\'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Vector_search_icon.svg/640px-Vector_search_icon.svg.png\' style=\'width:24px; height:24px\'></button>`);
      lb = document.getElementById("locateButton");
      lb.addEventListener("click", zoom_selected);
    }
    
    // HTML Table tags
    var eo = "<td>",
        ec = "</td>";
    
    
    
    // On Node Click
    d3.selectAll(".node").on("click", function(e, d) {
      // Update colour of item
      if(selected_item != ""){
        selected_item.style(selected_feat, selected_colour);
      }
      selected_item = d3.select(this);
      selected_feat = "fill";
      selected_colour = selected_item.style(selected_feat);
      selected_item.style(selected_feat, highlight);
      clicked_name = x.nodes.name[d];
      
      // Get isolated documents and build table with them
      docs = x.documents;
      var matches = docs.Toponyms.reduce((a, e, i) => {
        splits = e.split(/:[a-zA-Z]{3}[,]?/);
        splits = splits.map(s => s.trim());
        splits = splits.filter((s) => s != "");
        if (splits.includes(clicked_name) && (splits.length === 1 || splits.filter((s) => s != clicked_name).length === 0))
          a.push(i);
        return a;
        }, []);
      isolates = `<div class=panel-heading style=\'height: ${panel_height*0.1}px;\'>Occurs as an isolate in ` + matches.length +  " documents</div>";
      isolates += `<div style=\'height: ${panel_height*0.665}px; width: ${panel_width*0.97}px; overflow-y: scroll; overflow-x: hidden;\'><table class=\'table table-striped\' style=\' table-layout: fixed;\'><thead><tr style=\'position: sticky; top: 0px; background: #eee;\'><th>Document</th><th>CTH</th><th>Found</th><th>Date</th><th>Ref. #</th></tr></thead><tbody>`;
      matches.forEach((m) => isolates += node_tooltip_html[4] + eo + docs.Textstelle[m] + ec + eo + docs.CTH[m] + ec + eo + docs.Fundort[m] + ec + eo + docs.Dat[m] + ec + eo + docs.RefNr[m] + ec + node_tooltip_html[7]);
      isolates += "</tbody></table></div>";
      
      // Obtain shared document names & counts
      matches = docs.Toponyms.reduce((a, e, i) => {
        splits = e.split(/:[a-zA-Z]{3}[,]?/);
        splits = splits.map(s => s.trim()); 
        splits = splits.filter((s) => s != "");
        if(splits.includes(clicked_name) && splits.filter((s) => s != clicked_name).length != 0)
            a.push(i);
          return a;
        }, []);
      unique_links = matches.map(s => docs.Toponyms[s].split(/[,]+/));
      unique_links = Array.from(new Set([].concat(...unique_links).map(s => s.trim())));
      unique_links = unique_links.filter((t) => !t.includes(clicked_name+":"));
      
      unique_docs = matches.map((m) => docs.Toponyms[m]);
      unique_docs = unique_docs.map((d) => d.split(/[,]+/));
      ctcts = Object.fromEntries(unique_links.map(x => [x, 0])); // Connections to Counts (of connections)
      unique_docs.forEach((a) => a.filter((t) => !t.includes(clicked_name+":")).forEach((t) => ctcts[t.trim()] += 1) );
      
      // Construct inner & outer tables of shared documents
      window.uit = function uit(e){
        current = e.target;
        if (current.innerHTML === "Expand"){
          e.target.innerHTML = "Collapse";
        }
        else{
          e.target.innerHTML = "Expand";
        }
      }
      function buttonIDFix(t){
        return t.split(/[:]+/).join("").replace(" ", "_").replace("?", "q");
      }
      function tableIDFix(t){
        return t.split(/[:]+/).join("").replace("[", "_").replace("]", "_");
      }
      function innerTable(toponym){
        inner = [`<tr class="collapse table_${tableIDFix(toponym)}"><td colspan="999"><div><table class="table table-striped"><thead><tr style=\'background: #eee;\'><th>Document</th><th>CTH</th><th>Found</th><th>Date</th><th>Ref. #</th></tr></thead><tbody>`, `</tbody></table></div></td></tr>`];
        tab = inner[0];
        matches.filter((t) => docs.Toponyms[t].includes(toponym)).forEach((d) => tab += "<tr>" + `${eo}${docs.Textstelle[d]}${ec}${eo}${docs.CTH[d]}${ec}${eo}${docs.Fundort[d]}${ec}${eo}${docs.Dat[d]}${ec}${eo}${docs.RefNr[d]}${ec}` + "</tr>");
        return tab + inner[1];
      }
      connections = `<div class=panel-heading style=\'height: ${panel_height*0.1}px;\'>Co-occurs with ` + unique_links.length +  " unqiue toponyms in " + matches.length + " documents</div>";
      connections += `<div style=\'height: ${panel_height*0.665}px; width: ${panel_width*0.97}px; overflow-y: scroll; overflow-x: hidden;\'><table class=table table-responsive table-hover><thead><tr style=\'position: sticky; top: 0px; background: #eee;\'><th>Toponym</th><th>Co-occurrences</th><th></th></tr></thead><tbody>`;
      Object.keys(ctcts).sort().forEach((m) => { 
        connections += `<tr data-toggle=collapse id=table_${tableIDFix(m)} data-target=.table_${tableIDFix(m)}>` + eo + m.split(/[:]+/)[0] + ec + eo + ctcts[m] + ec + eo + `<button id=${buttonIDFix(m)}_btn class=btn btn-default btn-sm onClick="uit(this.id)">Expand</button>` + ec + "</tr>" + innerTable(m);
      }); 
      connections += "</tbody></table></div>"; 

      // Update info box HTML content with all tables
      info_html = info_panel_node[0] + clicked_name + info_panel_node[1] + x.nodes.group[d] + info_panel_node[2] + info_panel_node[3] + info_panel_node[4] + nodeLinkPanel[0] + connections + nodeLinkPanel[1] + nodeIsoPanel[0] + isolates + nodeIsoPanel[1] + info_panel_node[5];
      infobox.html(info_html);
      Object.keys(ctcts).sort().forEach((m) => { 
        document.getElementById(`${buttonIDFix(m)}_btn`).addEventListener("click", uit);
      }); 
      
      // Info Box HTML stylings & position
      info_layer.attr("width", panel_width).attr("height", panel_height).attr("x", (d3.select("svg").node().clientWidth/1)-panel_width);
      infobox.style("width", panel_width + "px").style("height", panel_height + "px");
      infobox.selectAll(".tab-content").style("padding", "10px").style("display", "flex").style("justify-content", "center");
      infobox.selectAll("li").style("width", "46%").style("text-align", "center").style("display", "inline-block");
      
      // Finish with adding button/window transformation
      d3.select("#t1b").on("click", select_cooccurs);
      d3.select("#t2b").on("click", select_isolates);
      addQuit();
      addLoc(clicked_name);
      trnsfinf();
    });
    
    
    
    // On Link Click
    d3.selectAll(".link").on("click", function(e, d) {
      // Update colour of item
      if(selected_item != ""){
        selected_item.style(selected_feat, selected_colour);
      }
      selected_item = d3.select(this);
      selected_feat = "stroke";
      selected_colour = selected_item.style(selected_feat);
      selected_item.style(selected_feat, highlight);
    
      source_name = x.nodes.name[x.links.source[d]];
      target_name = x.nodes.name[x.links.target[d]];
      
      // Get indices of links in documents
      docs = x.documents;
      const matches = docs.Toponyms.reduce((a, e, i) => {
        splits = e.split(/[:,]+/);
        splits = splits.map(s => s.trim());
        if (splits.includes(target_name) && splits.includes(source_name))
            a.push(i);
        return a;
      }, []);

      // Update the Information Box to correct pos
      info_layer.attr("width", panel_width).attr("height", panel_height).attr("x", (d3.select("svg").node().clientWidth/1)-panel_width);
      infobox.style("width", panel_width + "px").style("height", panel_height + "px");
      
      // Update info box html
      info_html = info_panel_select[0] + source_name + link_tooltip_html[1] + target_name + info_panel_select[1] + matches.length + info_panel_select[2] + info_panel_select[3];
      matches.forEach((m) => info_html += node_tooltip_html[4] + eo + docs.Textstelle[m] + ec + eo + docs.CTH[m] + ec + eo + docs.Fundort[m] + ec + eo + docs.Dat[m] + ec + eo + docs.RefNr[m] + ec + node_tooltip_html[7]);
      info_html = info_html + info_panel_select[4];
      infobox.html(info_html);
      
      // Finish with adding button/window transformation
      addQuit();
      trnsfinf();
    });
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