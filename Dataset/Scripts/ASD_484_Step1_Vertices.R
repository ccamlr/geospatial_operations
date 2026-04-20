#Script to build/update Master Vertices

#Set the name of the polygon
pName="48.4"

#Set the name of this script
sName="ASD_484_Step1_Vertices.R"



#The rest should be automatic

#Load Helpers
source("Dataset/Scripts/Z_Helpers.R")

#1. Load Primary, Secondary and Master Vertices
Vs=Load_Vs(Type=c("P","S","M"))
PV=Vs$PV #Primary Vertices
SV=Vs$SV #Secondary Vertices
MV=Vs$MV #Master Vertices
rm(Vs)

#2. Generate Secondary vertices and verify they are the same as loaded
#2.1. Subareas 48.2/3 vertices
SVtmp=data.frame(
  Latitude=-57,
  Longitude=-30,
  Vertex="S8"
)
#Check identity
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}

#3. Build Master vertices and verify they are the same as loaded
MVtmp=bind_rows(
  PV[which(PV$Vertex=="P1"),(1:3)],
  SV[which(SV$Vertex=="S8"),(1:3)],
  PV[which(PV$Vertex=="P2"):which(PV$Vertex=="P4"),(1:3)]
)
MVtmp$Name=pName

#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()
