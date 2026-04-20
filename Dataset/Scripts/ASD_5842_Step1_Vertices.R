#Script to build/update Master Vertices

#Set the name of the polygon
pName="58.4.2"

#Set the name of this script
sName="ASD_5842_Step1_Vertices.R"



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
#S28: New SV to mark corner of 58.4.4a/b
SVtmp=data.frame(
  Latitude=-62,
  Longitude=43,
  Vertex="S28"
)

#S29: New SV to mark corner of 58.4.4b/58.4.3a
tmp=data.frame(
  Latitude=-62,
  Longitude=60,
  Vertex="S29"
)

SVtmp=rbind(SVtmp,tmp)
#Check identity
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}


#3. Build Master vertices and verify they are the same as loaded
MVtmp=bind_rows(
  SV[which(SV$Vertex=="S13"),(1:3)],
  PV[which(PV$Vertex=="P2"),(1:3)],
  SV[which(SV$Vertex=="S28"):which(SV$Vertex=="S29"),(1:3)],
  PV[which(PV$Vertex=="P3"):which(PV$Vertex=="P5"),(1:3)],
  SV[which(SV$Vertex=="S26"),(1:3)],
  IV[which(IV$Vertex=="I74"):which(IV$Vertex=="I50"),(1:3)]
)
MVtmp$Name=pName
#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()