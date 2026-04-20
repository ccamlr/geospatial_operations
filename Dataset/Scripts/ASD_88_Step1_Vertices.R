#Script to build/update Master Vertices

#Set the name of the polygon
pName="88"

#Set the name of this script
sName="ASD_88_Step1_Vertices.R"



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
#S24 New SV to mark corner of 88.1/2
SVtmp=data.frame(
  Latitude=-60,
  Longitude=-170,
  Vertex="S24"
)

#S25 New SV to mark corner of 88.2/3
tmp=data.frame(
  Latitude=-60,
  Longitude=-105,
  Vertex="S25"
)
SVtmp=rbind(SVtmp,tmp)
#Check identity
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}


#3. Build Master vertices and verify they are the same as loaded
MVtmp=bind_rows(
  SV[which(SV$Vertex=="S17"),(1:3)],
  PV[which(PV$Vertex=="P2"),(1:3)],
  SV[which(SV$Vertex=="S18"):which(SV$Vertex=="S19"),(1:3)],
  SV[which(SV$Vertex=="S24"):which(SV$Vertex=="S25"),(1:3)],
  PV[which(PV$Vertex=="P3"),(1:3)],
  SV[which(SV$Vertex=="S5"):which(SV$Vertex=="S1"),(1:3)],
  IV[which(IV$Vertex=="I140"):which(IV$Vertex=="I114"),(1:3)],
  SV[which(SV$Vertex=="S21"):which(SV$Vertex=="S22"),(1:3)],
  IV[which(IV$Vertex=="I113"):which(IV$Vertex=="I96"),(1:3)]
)
MVtmp$Name=pName
#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()