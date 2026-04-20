#Script to build/update Points

pName="CEMP"
#Set the name of this script
sName="CEMP_Step2_Points.R"

#The rest should be automatic

#Load Helpers
source("Dataset/Scripts/Z_Helpers.R")

#Load coastline (if it wasn't loaded in '0_Run_Scripts')
if(exists("COAST")==F){
  coast=load_Coastline()
  coast=coast[coast$surface=="Land",]
  coast=st_union(coast)
}else{
  coast=COAST
}

#Fake Master Vertices for plots
MV=CEMP


#Build Master and plot
P_Master=create_Points(CEMP)
P_Master$ID=P_Master$Name
BB=st_bbox(st_buffer(P_Master,20000)) #Get bounding box (x/y limits) + buffer
coast=suppressWarnings(st_intersection(coast,st_as_sfc(BB))) #Crop coast

Plot_master()

#clip to the coastline (if any) and plot
P_Clipped=P_Master

Plot_clipped()

#Add Metadata
MD=Add_Metadata()
P_Master=st_set_geometry(MD,st_geometry(P_Master))
P_Clipped=st_set_geometry(MD,st_geometry(P_Clipped))

#Export
Export_Pol()

message(paste0(sName," done."))
gc()