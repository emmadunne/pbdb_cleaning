# Cleaning PBDB Fossil Occurrence Data

Fossil occurrence data downloaded from the Paleobiology Database (PBDB), no matter how exact you with choosing the criteria on the download form, can often still contain occurrences that are not useful. The script here shows an example procedure for 'cleaning' data i.e. eliminating unwanted occurrences. 

In this script, I download fossil occurrences directly to a .csv file using the [download form](https://paleobiodb.org/classic/displayDownloadGenerator). You can alternatively use the API (documentation for this can be found [here](https://paleobiodb.org/data1.1/)) or by using a package such as [paleobioDB](https://github.com/ropensci/paleobioDB) or [velociraptr](https://cran.r-project.org/web/packages/velociraptr/index.html).
