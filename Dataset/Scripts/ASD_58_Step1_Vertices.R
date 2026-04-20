#Script to build/update Master Vertices

#Set the name of the polygon
pName="58"

#Set the name of this script
sName="ASD_58_Step1_Vertices.R"



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
#S47: New SV to mark corner of 48.6/58.4.4a
SVtmp=data.frame(
  Latitude=-50,
  Longitude=30,
  Vertex="S47"
)
#S48: New SV to mark corner of 58.6/7
tmp=data.frame(
  Latitude=-45,
  Longitude=44,
  Vertex="S48"
)
SVtmp=rbind(SVtmp,tmp)
#S49: New SV to mark corner of 58.6/58.5.1
tmp=data.frame(
  Latitude=-45,
  Longitude=60,
  Vertex="S49"
)
SVtmp=rbind(SVtmp,tmp)
#S50: New SV to mark corner of 58.5.1/2
tmp=data.frame(
  Latitude=-49.4,
  Longitude=80,
  Vertex="S50"
)
SVtmp=rbind(SVtmp,tmp)
#S51: New SV to mark corner of 58.4.3b/58.4.1
tmp=data.frame(
  Latitude=-55,
  Longitude=86,
  Vertex="S51"
)
SVtmp=rbind(SVtmp,tmp)
#Check identity
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}


#3. Build Master vertices and verify they are the same as loaded
MVtmp=bind_rows(
  SV[which(SV$Vertex=="S13"):which(SV$Vertex=="S12"),(1:3)],
  SV[which(SV$Vertex=="S47"),(1:3)],
  PV[which(PV$Vertex=="P2"),(1:3)],
  SV[which(SV$Vertex=="S48"):which(SV$Vertex=="S49"),(1:3)],
  PV[which(PV$Vertex=="P3"),(1:3)],
  SV[which(SV$Vertex=="S50"),(1:3)],
  PV[which(PV$Vertex=="P4"),(1:3)],
  SV[which(SV$Vertex=="S51"),(1:3)],
  PV[which(PV$Vertex=="P5"),(1:3)],
  SV[which(SV$Vertex=="S27"),(1:3)],
  SV[which(SV$Vertex=="S17"),(1:3)],
  IV[which(IV$Vertex=="I95"):which(IV$Vertex=="I50"),(1:3)]
)
MVtmp$Name=pName
#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()