#Script to build/update Master Vertices

#Set the name of the polygon
pName="C.A."

#Set the name of this script
sName="CA_CA_Step1_Vertices.R"



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
#S52: New SV to mark corner of 88.3/48.1
SVtmp=data.frame(
  Latitude=-60,
  Longitude=-70,
  Vertex="S52"
)
#Check identity
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}


#3. Build Master vertices and verify they are the same as loaded
MVtmp=bind_rows(
  PV[which(PV$Vertex=="P1"),(1:3)],
  SV[which(SV$Vertex=="S15"):which(SV$Vertex=="S16"),(1:3)],
  PV[which(PV$Vertex=="P2"):which(PV$Vertex=="P3"),(1:3)],
  SV[which(SV$Vertex=="S48"):which(SV$Vertex=="S49"),(1:3)],
  PV[which(PV$Vertex=="P4"),(1:3)],
  SV[which(SV$Vertex=="S50"),(1:3)],
  PV[which(PV$Vertex=="P5"),(1:3)],
  SV[which(SV$Vertex=="S51"),(1:3)],
  PV[which(PV$Vertex=="P6"):which(PV$Vertex=="P7"),(1:3)],
  SV[which(SV$Vertex=="S18"):which(SV$Vertex=="S19"),(1:3)],
  SV[which(SV$Vertex=="S24"):which(SV$Vertex=="S25"),(1:3)],
  SV[which(SV$Vertex=="S52"),(1:3)],
  PV[which(PV$Vertex=="P8"),(1:3)],
  SV[which(SV$Vertex=="S14"),(1:3)]
)
MVtmp$Name=pName
#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()