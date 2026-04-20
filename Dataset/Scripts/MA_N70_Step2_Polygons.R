#Script to build/update Polygons

#Set the name of the polygon
pName="N70"

#Set the name of this script
sName="MA_N70_Step2_Polygons.R"




#NB this is a special case, with a hole inside the polygon!




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
#Cut hole inside polygon
HoleDF=data.frame(
  Name=pName,
  Latitude=c(-69,-66.75,-66.75,-66.75,-66.75,-69,-69,-69),
  Longitude=c(179,179,179.999999,-179.999999,-179,-179,-179.999999,179.999999)
)
Hole=create_Polys(HoleDF)
# HPs=create_Points(HoleDF[,2:3])
# par(mai=rep(0,4))
# plot(st_geometry(Hole))
# text(HPs$x,HPs$y,HPs$ID,col="red")
P_Master=suppressWarnings( st_difference(P_Master,st_geometry(Hole)) )

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