# ******************************************************
#
#       CLEANING FOSSIL OCCURRENCE DATA FROM 
#           THE PALEOBIOLOGY DATABASE
#
# ______________________________________________________
#
#               E. M. Dunne 2020
#
# ******************************************************


# In this script, we take a 'raw' occurrence dataset straight from the Paleobiology Database
# and remove any unwanted occurrences and taxa to make a species-level dataset of global 
# terrestrial tetrapod occurrences during the Late Triassic (Carnian <-  Rhaetian)




# Housekeeping ------------------------------------------------------------

## Clear the R environment
rm(list = ls())

## Package used in this script:
library(tidyverse)




# Import data file ----------------------------------------

## This example uses Late Triassic tetrapod occurrence data downloaded as a .csv file from:
## https://paleobiodb.org/classic/displayDownloadGenerator
## The dataset can also be directly downloaded using this URL:
## (http://paleobiodb.org/data1.2/occs/list.csv?datainfo&rowcount&base_name=Tetrapoda&ident=all&interval=Carnian,Rhaetian&private&show=full,classext,genus,ident,strat,env,ref,entname)


## Import downloaded data (and skip the 20 lines of metedata that accompanies each download):
pbdb_data <- tbl_df(read.csv("./data/PBDB_download_Late_Triassic_tetrapods.csv", header = TRUE, skip = 20, stringsAsFactors=FALSE))
pbdb_data # view tibble




# Create lists of taxa/terms to remove ------------------------------------


## Import lists of taxonomic names/terms that you'd like to remove (in this case it's: trace, egg and marine taxa):
## (NB: The lists below contain taxonomic names that occur across the Phanerozoic, not just the Late Triassic)
trace.terms <- scan("./data/to_remove/trace-terms.txt", what = "character"); trace.terms <- trace.terms[trace.terms != ""] # list of trace terms
egg.terms <- scan("./data/to_remove/egg-terms.txt", what = "character"); egg.terms <- egg.terms[egg.terms != ""] # list of egg terms
marine.terms <- scan("./data/to_remove/marine-terms.txt", what = "character"); marine.terms <- marine.terms[marine.terms != ""] # list of marine taxa


## Using a separate PBDB data download, you can remove entire taxonomic groups e.g. Pterosaurs (i.e. Late Triassic flying taxa) 
## CImport this downloaded data:
pterosauria <- read.csv("./data/to_remove/pterosauria.csv", header = TRUE, skip=18, stringsAsFactors = FALSE) # occurrence download of pterosaur occurrences
flying.terms <- unique(c(pterosauria$genus,
                         pterosauria$family)) # take out the family and genus names
flying.terms <- flying.terms[flying.terms != ""] # strip out any blank entries that might have crept in


## Now, collect all the lists from above and any additional individual taxa you want to exclude:
exclude.terms <- c( trace.terms, egg.terms, marine.terms, flying.terms,
                    "Crocodylus","Alligator","Testudo","Lacerta", # some wastebasket genera
                    "Fenestrosaurus","Ovoraptor","Ornithoides" # names from popular article by Osborne (1925) that should not be in the database
                    )
exclude.terms <- exclude.terms[exclude.terms != ""] # remove any blank entries that may have crept in


## Finally, filter out the taxa you want to exclude, ensuring that you do this for the genus, family, and order columns
pbdb_data <- pbdb_data[!(pbdb_data$order %in% exclude.terms), ] # from order column
pbdb_data <- pbdb_data[!(pbdb_data$family %in% exclude.terms), ] # from family column
pbdb_data <- pbdb_data[!(pbdb_data$genus %in% exclude.terms), ] # from genus column



# Filter out unwanted occurrences -----------------------------------------


## Next, filter out any re-identified taxa, super-generic' identifications, or indeterminate occurrences
pbdb_data <- filter(pbdb_data, flags != "R") # filter out reidentified taxa
pbdb_data <- filter(pbdb_data, (identified_rank %in% c("species","genus"))) # remove 'super-generic' identifications
pbdb_data <- pbdb_data %>% filter(!grepl("cf\\.|aff\\.|\\?|ex\\. gr\\.|sensu lato|informal|\\\"", identified_name)) # remove occurrences with “aff.”, “ex. gr.”, “sensu lato”, “informal”, or quotation marks


## Remove entries marked as 'trace' or 'soft', and those with no genus name (some of these might have already been removed in the section above)
pbdb_data <- pbdb_data[pbdb_data$pres_mode != "trace", ]
pbdb_data <- pbdb_data[!grepl("soft",pbdb_data$pres_mode), ]
pbdb_data <- pbdb_data[pbdb_data$genus != "", ]


## To make a species-level dataset (i.e. all taxa must be determinate at species level), subset the dataset using the accepted_rank column
#pbdb_data_sp <- subset(pbdb_data, accepted_rank == "species")



# Save copy of cleaned dataset --------------------------------------------

## Save a copy of the cleaned dataset:
write_csv(pbdb_data, "./data/Late_Triassic_tetrapod_occurrences_cleaned.csv")


