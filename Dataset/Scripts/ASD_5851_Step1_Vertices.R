#Script to build/update Master Vertices

#Set the name of the polygon
pName="58.5.1"

#Set the name of this script
sName="ASD_5851_Step1_Vertices.R"



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


#2. Generate Secondary vertices and verify they are the same as loaded
#S46: New SV to mark corner of 58.4.4b/58.6
SVtmp=data.frame(
  Latitude=-50,
  Longitude=60,
  Vertex="S46"
)
#Check identity
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}


#3. Build Master vertices and verify they are the same as loaded
MVtmp=bind_rows(
  PV[which(PV$Vertex=="P1"),(1:3)],
  SV[which(SV$Vertex=="S46"),(1:3)],
  PV[which(PV$Vertex=="P2"):which(PV$Vertex=="P4"),(1:3)],
  SV[which(SV$Vertex=="S43"):which(SV$Vertex=="S36"),(1:3)]
)
MVtmp$Name=pName
#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()