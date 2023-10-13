library(dplyr)

# Define data location
in_path <- "../toponym_data/"

# Load initial data and add category columns
oronyms <- distinct(read.csv(paste(in_path, "oronym.csv", sep="")))
hydronyms <- distinct(read.csv(paste(in_path, "hydronym.csv", sep="")))
choronyms <- distinct(read.csv(paste(in_path, "choronym.csv", sep="")))
oronyms$Type <- "Orornym"
hydronyms$Type <- "Hydronym"
choronyms$Type <- "Choronym"

# Append type of entry to Toponym to distinguish between identically named places
oronyms$Toponym <- paste(oronyms$Toponym, "oro", sep=":")
hydronyms$Toponym <- paste(hydronyms$Toponym, "hyd", sep=":")
choronyms$Toponym <- paste(choronyms$Toponym, "cho", sep=":")

# Define full dataset and empty DF for relations between entries
toponyms <- rbind(oronyms, hydronyms, choronyms)
relations <- data.frame(matrix(ncol = 3, nrow = 0))

# Construct unique relations between entries
for(doc in unique(toponyms$Textstelle)){
  docs <- sort(unique(toponyms[toponyms$Textstelle == doc, "Toponym"]))
  if(length(docs) < 2)   # Documents with only 1 entry are irrelevant
    # message(paste("Only 1 entry for", doc))
    next
  combos <- combn(docs, 2)
  combos <- data.frame(combos[1,], combos[2,], doc)
  relations <- rbind(relations, combos)
}
colnames(relations) <- c("To", "From", "Document")

# Compute counts of Toponyms
entry_counts <- table(toponyms$Toponym)
entry_counts <- as.data.frame(entry_counts)
colnames(entry_counts) <- c("Toponym", "Freq")

# Compute counts of relations
relation_counts <- relations
relation_counts <- group_by(relation_counts, To, From) %>% 
  summarise(total_count=n(),.groups = 'drop') %>% as.data.frame()