library(rvest)
library(purrr)

# Define links and toponym categories
out_path <- "../toponym_data/"
ht <- "https://www.hethport.uni-wuerzburg.de/HiTop/hetgeo"
categories <- c("lemma.php?g=b", "lemma.php?g=g", "lemma.php?g=l", "lemma.php?g=o")
cat_string <- c("oronym", "hydronym", "choronym", "oikonym")
assertthat::are_equal(length(categories), length(cat_string))

# Begin reading the toponyms (for all categories, replace below with 1:4)
for(c in 4:4){
  # Read category page and format the list of entries 
  page <- read_html(paste(ht, categories[c], sep = ""))
  tpl <- page %>% html_nodes("ol") %>%  map(~html_nodes(.x, 'li') %>% html_nodes("a") %>% html_attr("href"))
  tpl <- unlist(tpl, recursive=FALSE) 
  tpl <- gsub("hetgeo", "", tpl)
  
  entries <- NA
  for(i in 1:length(tpl)){
    # Load the next document and format it into a dataframe 
    doc <- tpl[i]
    entry <- tryCatch(read_html(paste(ht, sub(" ", "%20", doc), sep="")),
             error=function(e){
               message(paste("Error accesing", doc))
               return(e)
             })
    if(inherits(entry, "error")) next  # Checks we can access the page
    entry <- entry %>% html_nodes(xpath="/html/body/div/div/div[4]/div[4]/div/table") %>% html_table()
    entry <- data.frame(entry)
    
    # Check that we have some data
    if(nrow(entry) < 1) next
    
    # Update column names
    entry$Toponym <- sub(".*=", "", doc)
    colnames(entry) <- gsub("[X.U.2195..]|\\.*", "", colnames(entry))
    
    # Combine the document with all accumulated entries
    if(is.na(entries)){
      entries <- entry
    }
    else{
      entries <- rbind(entries, entry)
    }
    
    # Sleep to help server then export existing data
    Sys.sleep(2.5)
    write.csv(entries, paste(out_path, cat_string[c], ".csv" ,sep=""), row.names=FALSE) 
  }
}