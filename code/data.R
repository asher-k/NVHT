library(plyr)
library(dplyr)
library(readr)
library(purrr)
library(stringr)

# Define data location
in_path <- "../toponym_data/"

# Load initial data and add category columns
oronyms <- distinct(read_csv(paste(in_path, "oronym.csv", sep=""),locale = locale(encoding = "Windows-1252")))
hydronyms <- distinct(read_csv(paste(in_path, "hydronym.csv", sep=""), locale = locale(encoding = "Windows-1252")))
choronyms <- distinct(read_csv(paste(in_path, "choronym.csv", sep=""), locale = locale(encoding = "Windows-1252")))
oikonyms <- distinct(read_csv(paste(in_path, "oikonym.csv", sep=""), locale = locale(encoding = "Windows-1252")))
oronyms$Type <- "Orornym"
hydronyms$Type <- "Hydronym"
choronyms$Type <- "Choronym"
oikonyms$Type <- "Oikonym"

# Remove Oikonyms which already exist as a Choronym
oikonyms <- subset(oikonyms, !(Toponym %in% choronyms$Toponym))

# Append type of entry to Toponym to distinguish between identically named places
oronyms$Toponym <- paste(oronyms$Toponym, "oro", sep=":")
hydronyms$Toponym <- paste(hydronyms$Toponym, "hyd", sep=":")
choronyms$Toponym <- paste(choronyms$Toponym, "cho", sep=":")
oikonyms$Toponym <- paste(oikonyms$Toponym, "oik", sep=":")

# Define full dataset and empty DF for relations between entries
toponyms <- rbind(oronyms, hydronyms, choronyms, oikonyms)
relations <- data.frame(matrix(ncol = 3, nrow = 0))

# Construct unique relations between entries
for(doc in unique(toponyms$Textstelle)){
  docs <- pull(unique(toponyms[toponyms$Textstelle == doc, "Toponym"]))
  if(length(docs) < 2)   # Documents with only 1 entry are irrelevant
    # message(paste("Only 1 entry for", doc))
    next
  combos <- combn(docs, 2)
  combos <- data.frame(combos[1,], combos[2,], doc)
  
  relations <- rbind(relations, combos)
}
colnames(relations) <- c("To", "From", "Document")

# Compute counts of relations
relation_counts <- relations
relation_counts <- group_by(relation_counts, To, From) %>% 
  summarise(total_count=n(),.groups = 'drop') %>% as.data.frame()  

# Restructure toponym data for displaying document information
mergedoc <- function(x){
  x <- unique(x)
  x <- paste(x, collapse=', ')
  return(x)
}
documents <- toponyms[,-c(1:3, 10)]
documents <- documents %>% group_by(Textstelle, CTH, Fundort, Dat, RefNr) %>% summarise(Toponyms = mergedoc(Toponym))

# Compute counts of Toponyms
mapped_counts = map(documents$Toponyms, function(t) unlist(str_split(t, ", ")))
mapped_counts = t(as.data.frame(flatten(mapped_counts)))
entry_counts = as.data.frame(table(mapped_counts))
colnames(entry_counts) <- c("Toponym", "Freq")