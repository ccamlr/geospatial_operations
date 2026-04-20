#Script to build/update Master Vertices

#Set the name of the polygon
pName="58.5.2"

#Set the name of this script
sName="ASD_5852_Step1_Vertices.R"



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
#S36-S43: New SVs to mark the boundary of 58.5.1/2 (As per FAO definition of 58.5.2)
SVtmp=data.frame(
  Latitude=c(-53.235278,-52.707778,-51.971667,-51.408889,-51.052500,-50.906389,-49.826111,-49.401944),
  Longitude=c(67.055556,68.091944,69.733889,71.208056,72.474444,72.822500,75.602222,76.704722),
  Vertex=paste0("S",seq(36,43))
)
#S44: New SV to mark corner of 58.4.3b
tmp=data.frame(
  Latitude=-55,
  Longitude=80,
  Vertex="S44"
)
SVtmp=rbind(SVtmp,tmp)
#S45: New SV to mark corner of 58.4.3a/b
tmp=data.frame(
  Latitude=-56,
  Longitude=73.166667,
  Vertex="S45"
)
SVtmp=rbind(SVtmp,tmp)
#Check identity
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}


#3. Build Master vertices and verify they are the same as loaded
MVtmp=bind_rows(
  PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
  SV[which(SV$Vertex=="S36"):which(SV$Vertex=="S43"),(1:3)],
  PV[which(PV$Vertex=="P3"),(1:3)],
  SV[which(SV$Vertex=="S44"),(1:3)],
  PV[which(PV$Vertex=="P4"),(1:3)],
  SV[which(SV$Vertex=="S45"),(1:3)]
)
MVtmp$Name=pName
#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()