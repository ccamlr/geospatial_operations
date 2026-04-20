#Script to build/update Polygons

#Set the name of the polygon
pName="483C"

#Set the name of this script
sName="MA_483C_Step2_Polygons.R"



#The rest should be automatic

#Load Helpers
source("Dataset/Scripts/Z_Helpers.R")

#Load Master Vertices
Vs=Load_Vs(Type="M")
MV=Vs$MV #Master Vertices

#Load coastline (if it wasn't loaded in '0_Run_Scripts')
if(exists("COAST")==F){
  coast=load_Coastline()
  coast=coast[coast$surface=="Land",]
  coast=st_union(coast)
}else{
  coast=COAST
}


#Build Master polygon and plot
P_Master=create_Polys(Input = data.frame(Name=pName,
                                  Lat=MV$Latitude,
                                  Lon=MV$Longitude))
BB=st_bbox(st_buffer(P_Master,20000)) #Get bounding box (x/y limits) + buffer
coast=suppressWarnings(st_intersection(coast,st_as_sfc(BB))) #Crop coast

Plot_master()

#clip to the coastline (if any) and plot
P_Clipped=NULL
tryCatch({
  P_Clipped=suppressWarnings(st_difference(P_Master,coast))
},error=function(e){message(paste0("No coastline to clip for ",pName))})
if(is.null(P_Clipped)){P_Clipped=P_Master}

Plot_clipped()

#Add Metadata
MD=Add_Metadata()
P_Master=st_set_geometry(MD,st_geometry(P_Master))
P_Clipped=st_set_geometry(MD,st_geometry(P_Clipped))

#Export
Export_Pol()

message(paste0(sName," done."))
gc()