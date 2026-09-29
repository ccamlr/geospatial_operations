#Build a simple grid of polygons to calculate circumpolar flows (Experiment 3)
library(CCAMLRGIS)
library(dplyr)
#Load helper functions
source("Scripts/Functions.R")
Grid=Simple_grid(dlat=10,dlon=20)
write.csv(Grid,"Inputs/Grid_For_Experiment_3.csv",row.names=F)
