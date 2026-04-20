#Script to build/update Master Vertices

#Set the name of the polygon
pName="48"

#Set the name of this script
sName="ASD_48_Step1_Vertices.R"



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
#S14: New SV to mark 48.2/3 corners
SVtmp=data.frame(
  Latitude=-57,
  Longitude=-50,
  Vertex="S14"
)

#S15: New SV to mark 48.3/4 corners
tmp=data.frame(
  Latitude=-50,
  Longitude=-30,
  Vertex="S15"
)
SVtmp=rbind(SVtmp,tmp)

#S16: New SV to mark 48.4/6 corners
tmp=data.frame(
  Latitude=-50,
  Longitude=-20,
  Vertex="S16"
)
SVtmp=rbind(SVtmp,tmp)
#Check identity
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}


#3. Build Master vertices and verify they are the same as loaded
MVtmp=bind_rows(
  SV[which(SV$Vertex=="S1"):which(SV$Vertex=="S5"),(1:3)],
  PV[which(PV$Vertex=="P2"):which(PV$Vertex=="P3"),(1:3)],
  SV[which(SV$Vertex=="S14"),(1:3)],
  PV[which(PV$Vertex=="P4"),(1:3)],
  SV[which(SV$Vertex=="S15"):which(SV$Vertex=="S16"),(1:3)],
  PV[which(PV$Vertex=="P5"),(1:3)],
  SV[which(SV$Vertex=="S12"):which(SV$Vertex=="S13"),(1:3)],
  IV[which(IV$Vertex=="I49"):which(IV$Vertex=="I6"),(1:3)],
  IV[which(IV$Vertex=="I143"):which(IV$Vertex=="I141"),(1:3)]
)
MVtmp$Name=pName
#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()