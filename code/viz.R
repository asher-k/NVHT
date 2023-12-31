library(igraph)
library(networkD3)
library(scales)
library(stringi)
library(plyr)
library(gsubfn)

# run locally? export dir?
local <- FALSE
out_dir <- "./shiny_data/"

# First reformat Toponym counts
ecs <- entry_counts 
ecs$Type <- gsub(".+:", "", ecs$Toponym)
ecs$Type <- mapvalues(ecs$Type, c("cho", "hyd", "oro", "oik"), c("Choronym", "Hydronym", "Oronym", "Oikonym"))
ecs$Toponym <- stri_unescape_unicode(gsub("<U\\+(....)>", "\\\\u\\1", ecs$Toponym))
if(local){
  documents <- read_csv("./shiny_data/doc.csv")
}

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

# Update documents to ensure Toponyms are displayed correctly in info table
documents$Fundort <- stri_unescape_unicode(gsub("<U\\+(....)>", "\\\\u\\1", documents$Fundort))
documents$Toponyms <- stri_unescape_unicode(gsub("<U\\+(....)>", "\\\\u\\1", documents$Toponyms))

# Define params for the network graph 
ColourScale <- 'd3.scaleOrdinal().domain(["Choronym", "Hydronym", "Oronym", "Oikonym"]).range(["#f2428f", "#41a7e2", "#9e7955", "#bcb6d9"]);'
def_table_rows <- 5

# Either display the network if running locally, or export the data for Shiny
if(local){
  source("widget.R", local = TRUE)
  n <- forceNetwork(Links=rcs, Source="From", Target="To", Value="total_count", 
                    Nodes=ecs, NodeID="Toponym", Group="Type", Nodesize="Freq",
                    colourScale = ColourScale, linkDistance = 200, charge = -100, zoom=T,
                    fontSize = 20, fontFamily = "serif", linkColour = "#666", opacity=1.0, opacityNoHover = TRUE, legend=T
  )
  n$x$options <- c(n$x$options, TableRows=def_table_rows)
  n$x$documents = documents
  n <- htmlwidgets::onRender(n, jsCode = tooltip)
  # And Display! (local only)
  n
}else{
  write.csv(ecs, paste(out_dir, "ecs.csv" ,sep=""), row.names=FALSE) 
  write.csv(rcs, paste(out_dir, "rcs.csv" ,sep=""), row.names=FALSE)
  write.csv(documents, paste(out_dir, "doc.csv" ,sep=""), row.names=FALSE) 
}