#Script to build/update Master Vertices

#Set the name of the polygon
pName="58.4.4b"

#Set the name of this script
sName="ASD_5844b_Step1_Vertices.R"



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
#S32: New SV to mark corner of 58.6/7
SVtmp=data.frame(
  Latitude=-50,
  Longitude=44,
  Vertex="S32"
)
#S33: New SV to mark corner of 58.5.1/2
tmp=data.frame(
  Latitude=-53.233333,
  Longitude=60,
  Vertex="S33"
)
SVtmp=rbind(SVtmp,tmp)
#S34: New SV to mark corner of 58.5.2/58.4.3a
tmp=data.frame(
  Latitude=-56,
  Longitude=60,
  Vertex="S34"
)
SVtmp=rbind(SVtmp,tmp)
#Check identity
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}


#3. Build Master vertices and verify they are the same as loaded
MVtmp=bind_rows(
  PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
  SV[which(SV$Vertex=="S32"),(1:3)],
  PV[which(PV$Vertex=="P3"),(1:3)],
  SV[which(SV$Vertex=="S33"):which(SV$Vertex=="S34"),(1:3)],
  PV[which(PV$Vertex=="P4"),(1:3)]
)
MVtmp$Name=pName
#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()