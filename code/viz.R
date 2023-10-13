library(igraph)
library(networkD3)
library(scales)

# Light reformatting of the relationship data
ecs <- entry_counts 
ecs$Freq <- rescale(ecs$Freq, t=c(3,30))
ecs$Type <- gsub(".+:", "", ecs$Toponym)
ecs$Toponym <- gsub(":[a-zA-Z]*", "", ecs$Toponym)

# Start the network
p <- forceNetwork(relation_counts,
                  Nodes=ecs,
                  NodeID="Toponym",
                  Nodesize="Freq", 
                  height="1000px", 
                  width="1000px",        
                  Source="From",                 # column number of source
                  Target="To",                 # column number of target
                  Group="Type",
                  linkDistance = 100,          # distance between node. Increase this value to have more space between nodes
                  charge = -900,                # numeric value indicating either the strength of the node repulsion (negative value) or attraction (positive value)
                  fontSize = 14,               # size of the node names
                  fontFamily = "serif",       # font og node names
                  linkColour = "#666",        # colour of edges, MUST be a common colour for the whole graph
                  opacity = 0.9,              # opacity of nodes. 0=transparent. 1=no transparency
                  zoom = T                    # Can you zoom on the figure?
)
p  # Doesn't display, hmmm.