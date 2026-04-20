#Script to build/update Master Vertices

#Set the name of the polygon
pName="58.6"

#Set the name of this script
sName="ASD_586_Step1_Vertices.R"



#The rest should be automatic

#Load Helpers
source("Dataset/Scripts/Z_Helpers.R")

#1. Load Vertices
Vs=Load_Vs()
PV=Vs$PV #Primary Vertices
IV=Vs$IV #Inland Vertices
SV=Vs$SV #Secondary Vertices
MV=Vs$MV #Master Vertices
rm(Vs)


#2. Build Master vertices and verify they are the same as loaded
MVtmp=PV
MVtmp$Latitude=as.numeric(MVtmp$Latitude)
MVtmp$Name=pName
#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()