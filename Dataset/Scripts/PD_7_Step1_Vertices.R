#Script to build/update Master Vertices

#Set the name of the polygon
pName="7"

#Set the name of this script
sName="PD_7_Step1_Vertices.R"



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
  SV[which(SV$Vertex=="S13"),(1:3)],
  PV[which(PV$Vertex=="P2"),(1:3)],
  SV[which(SV$Vertex=="S28"),(1:3)],
  SV[which(SV$Vertex=="S29"),(1:3)],
  SV[which(SV$Vertex=="S31"),(1:3)],
  PV[which(PV$Vertex=="P3"):which(PV$Vertex=="P5"),(1:3)],
  SV[which(SV$Vertex=="S27"),(1:3)],
  SV[which(SV$Vertex=="S17"),(1:3)],
  IV[which(IV$Vertex=="I95"):which(IV$Vertex=="I50"),(1:3)],
)
MVtmp$Name=pName
# write.csv(MVtmp,paste0(Root,"/Inputs/tmp.csv"),row.names=F)
# qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green")


#Check identity between MVtmp and the existing MV.
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()