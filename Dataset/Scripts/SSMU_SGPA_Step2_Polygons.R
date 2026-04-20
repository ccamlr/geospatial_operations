#Script to build/update Polygons

#Set the name of the polygon
pName="SGPA"

#Set the name of this script
sName="SSMU_SGPA_Step2_Polygons.R"


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

#Build Master polygon and plot
#Build Subarea 48.3
Vs=Load_Vs(Type="M",pname="48.3")
MV=Vs$MV #Master Vertices
rm(Vs)
P_Master=create_Polys(Input=data.frame(Name=pName,
                                       Lat=MV$Latitude,
                                       Lon=MV$Longitude))

#Build SSMUs
Vs=Load_Vs(Type="M",pname="SGE")
MV=Vs$MV #Master Vertices
rm(Vs)
P_Hole1=create_Polys(Input = data.frame(Name=pName,
                                         Lat=MV$Latitude,
                                         Lon=MV$Longitude))
#Compute difference
P_Master=suppressWarnings(st_difference(P_Master,st_geometry(P_Hole1)))

Vs=Load_Vs(Type="M",pname="SGW")
MV=Vs$MV #Master Vertices
rm(Vs)
P_Hole1=create_Polys(Input = data.frame(Name=pName,
                                        Lat=MV$Latitude,
                                        Lon=MV$Longitude))
#Compute difference
P_Master=suppressWarnings(st_difference(P_Master,st_geometry(P_Hole1)))

#plot(st_geometry(P_Master),col="red",lwd=3)

#Update Area and labs
P_Master$AreaKm2=as.numeric(round(st_area(P_Master)/1000000,1))
labs=st_coordinates(st_centroid(st_geometry(P_Master)))
P_Master$Labx=labs[,1]
P_Master$Laby=labs[,2]


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