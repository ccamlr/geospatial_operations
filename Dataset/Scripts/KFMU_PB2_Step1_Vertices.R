#Script to build/update Master Vertices

#Set the name of the polygon
pName="PB2"

#Set the name of this script
sName="KFMU_PB2_Step1_Vertices.R"


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

#3. Build Master vertices (turn your vertices plan into code)
MVtmp=bind_rows(
  PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
  SV[which(SV$Vertex=="S6"),(1:3)],
  PV[which(PV$Vertex=="P3"),(1:3)],
  IV[which(IV$Vertex=="I186"),(1:3)],
  SV[which(SV$Vertex=="S7"),(1:3)],
  IV[which(IV$Vertex=="I2"),(1:3)],
  SV[which(SV$Vertex=="S91"),(1:3)],
  SV[which(SV$Vertex=="S100"),(1:3)],
  SV[which(SV$Vertex=="S84"),(1:3)],
  SV[which(SV$Vertex=="S93"),(1:3)],
  IV[which(IV$Vertex=="I1"),(1:3)],
  IV[which(IV$Vertex=="I178"):which(IV$Vertex=="I183"),(1:3)],
  PV[which(PV$Vertex=="P8"),(1:3)],
  IV[which(IV$Vertex=="I184"):which(IV$Vertex=="I185"),(1:3)],
  PV[which(PV$Vertex=="P9"),(1:3)]
)
MVtmp$Name=pName
# write.csv(MVtmp,paste0(Root,"/Inputs/tmp.csv"),row.names=F) #Copy/paste this into Master Vertices, then re-run from top
# qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green")
# st_is_valid(qq)

#Check identity between MVtmp and the existing MV.
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()