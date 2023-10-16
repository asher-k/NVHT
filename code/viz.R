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