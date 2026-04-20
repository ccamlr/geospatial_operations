#Script to build/update Points

pName="VMEs"
#Set the name of this script
sName="VMEs_Step2_Points.R"

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

#Risk Areas
if(any(RA$buffer_size_nm!=1)){stop(paste0("A Risk Area buffer is not 1 nm wide. Check in ",sName))}
RA=create_Points(Input=RA[,c('latitude_mid','longitude_mid','Name')],Buffer=RA$buffer_size_nm)

#Fine Scale Rectangles
tmp=NULL
for(i in seq(1,nrow(FSR))){
  tmp=rbind(tmp,data.frame(
    Name=FSR$Name[i],
    Latitude=c(FSR$latitude_max[i],FSR$latitude_max[i],FSR$latitude_min[i],FSR$latitude_min[i]),
    Longitude=c(FSR$longitude_min[i],FSR$longitude_max[i],FSR$longitude_max[i],FSR$longitude_min[i])
  ))
}
FSR=create_Polys(tmp)

#Registered VMEs (CM 22-09)
R_VMEs=create_Points(Input=RegBP[,c('latitude_mid','longitude_mid','Name')],Buffer=RegBP$buffer_size_nm)

#VME encounters (CM 22-06)
# Lon1=150
# Lat1=-70
# Lon2=Lon1+0.00001
# Lat2=Lat1+0.00001
# distVincentyEllipsoid(c(Lon1,Lat1),c(Lon2,Lat2))
RegP$latitude_max=RegP$latitude_min+0.00001
RegP$longitude_max=RegP$longitude_min+0.00001
VME_E=rbind(RegL,RegP)

VME_E=data.frame(
  Name=c(VME_E$Name,VME_E$Name),
  Lat=c(VME_E$latitude_min,VME_E$latitude_max),
  Lon=c(VME_E$longitude_min,VME_E$longitude_max)
)
VME_E=create_Lines(VME_E)


#Fake Master Vertices for plots
VMEs=VME_E%>%select(ID)
VMEs=rbind(VMEs,FSR%>%select(ID))
VMEs=rbind(VMEs,RA%>%select(ID=Name))
VMEs=rbind(VMEs,R_VMEs%>%select(ID=Name))
row.names(VMEs)=NULL

MV=st_cast(VMEs,"MULTIPOINT")
MV=suppressWarnings(st_cast(MV,"POINT"))
MV=as.data.frame(st_coordinates(MV))
MV=project_data(MV,NamesIn = c("Y","X"),NamesOut = c("Lat","Lon"),inv=T,append = F)

#Build Master and plot
P_Master=VMEs
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

#Export#Add Metadata
MD=Add_Metadata()
P_Master=st_set_geometry(MD,st_geometry(P_Master))
P_Clipped=st_set_geometry(MD,st_geometry(P_Clipped))

#Export
Export_Pol(Fname="VME")

message(paste0(sName," done."))
gc()