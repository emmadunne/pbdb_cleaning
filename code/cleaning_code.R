# ******************************************************
#
#       CLEANING FOSSIL OCCURRENCE DATA FROM 
#           THE PALEOBIOLOGY DATABASE
#
# ______________________________________________________
#
#               E.M. Dunne 2020
#
# ******************************************************

## This example uses Late Triassic tetrapod occurrence data downloaded from:
## https://paleobiodb.org/classic/displayDownloadGenerator




# Housekeeping ------------------------------------------------------------

## First, clear the R environment
rm(list = ls())

## Packages used in this script:
library(tidyverse)




# Import and clean occurrence data ----------------------------------------


## Import downloaded data, or import directly from URL:
## (http://paleobiodb.org/data1.2/occs/list.csv?datainfo&rowcount&base_name=Tetrapoda&ident=all&interval=Carnian,Rhaetian&private&show=full,classext,genus,ident,strat,env,ref,entname)
pbdb_data <- tbl_df(read.csv("./PBDB_download_Late_Triassic_tetrapods.csv", header = TRUE, skip = 20, stringsAsFactors=FALSE))


## Filter out any re-identified taxa, super-generic' identifications, or indeterminate occurrences
pbdb_data <- filter(pbdb_data, flags != "R") # filter out reidentified taxa
pbdb_data <- filter(pbdb_data, (identified_rank %in% c("species","genus"))) # remove 'super-generic' identifications
pbdb_data <- pbdb_data %>% filter(!grepl("cf\\.|aff\\.|\\?|ex\\. gr\\.|sensu lato|informal|\\\"", identified_name)) # remove occurrences with “aff.”, “ex. gr.”, “sensu lato”, “informal”, or quotation marks


## Remove entries marked as 'trace' or 'soft', and those with no genus name
pbdb_data <- pbdb_data[pbdb_data$pres_mode != "trace", ]
pbdb_data <- pbdb_data[!grepl("soft",pbdb_data$pres_mode), ]
pbdb_data <- pbdb_data[pbdb_data$genus != "", ]


## Then use txt files of trace, egg and marine names stored in text files to remove those occurrences
trace.terms <- scan("./input-data/trace-terms.txt", what = "character"); trace.terms <- trace.terms[trace.terms != ""]
egg.terms <- scan("./input-data/egg-terms.txt", what = "character"); egg.terms <- egg.terms[egg.terms != ""]
marine.terms <- scan("./input-data/marine-terms.txt", what = "character"); marine.terms <- marine.terms[marine.terms != ""] # updated Feb 3rd 2019
pterosauria <- read.csv("./input-data/pterosauria.csv", header = TRUE, skip=18, stringsAsFactors = FALSE) # data download of pterosaur occurrences
flying.terms <- unique(c(
  pterosauria$genus,
  pterosauria$family
)) # create character vector of flying taxa
flying.terms <- flying.terms[flying.terms != ""] # strip any potential blank entries


## Collect all the terms to exclude
exclude.terms <- c( trace.terms, egg.terms, marine.terms, flying.terms,
                    "Crocodylus","Alligator","Testudo","Lacerta", # wastebasket genera
                    "Fenestrosaurus","Ovoraptor","Ornithoides" # names from popular article by Osborne (1925) that should not be in the database
)
exclude.terms <- exclude.terms[exclude.terms != ""] #remove any blank entries that may have crept in

## Strip out everything that needs to be excluded
pbdb_data <- pbdb_data[!(pbdb_data$order %in% exclude.terms), ] # from order column
pbdb_data <- pbdb_data[!(pbdb_data$family %in% exclude.terms), ] # from family column
pbdb_data <- pbdb_data[!(pbdb_data$genus %in% exclude.terms), ] # from genus column


## Save a copy of the cleaned dataset:
write.csv(pbdb_data, file = "./Late_Triassic_tetrapod_occurrences_cleaned.csv")



