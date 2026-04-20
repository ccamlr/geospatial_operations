#Script to build/update Master Vertices

#Set the name of the polygon
pName="58.4.4a"

#Set the name of this script
sName="ASD_5844a_Step1_Vertices.R"



#The rest should be automatic

#Load Helpers
source("Dataset/Scripts/Z_Helpers.R")

#1. Load Primary and Master Vertices
Vs=Load_Vs(Type=c("P","M"))
PV=Vs$PV #Primary Vertices
MV=Vs$MV #Master Vertices
rm(Vs)

#2. Build Master vertices and verify they are the same as loaded
MVtmp=PV
MVtmp$Latitude=as.numeric(MVtmp$Latitude)
MVtmp$Longitude=as.numeric(MVtmp$Longitude)
MVtmp$Name=as.character(MVtmp$Name)

#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()
