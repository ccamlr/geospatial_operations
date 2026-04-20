#Script to build/update Master Vertices

#Set the name of the polygon
pName="SSIW"

#Set the name of this script
sName="KFMU_SSIW_Step1_Vertices.R"


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
  PV[which(PV$Vertex=="P1"),(1:3)],
  IV[which(IV$Vertex=="I173"):which(IV$Vertex=="I144"),(1:3)],
  PV[which(PV$Vertex=="P3"):which(PV$Vertex=="P5"),(1:3)]
)
MVtmp$Name=pName
# write.csv(MVtmp,paste0(Root,"/Inputs/tmp.csv"),row.names=F) #Copy/paste this into Master Vertices, then re-run from top
# qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green")
# st_is_valid(qq)

#Check identity between MVtmp and the existing MV.
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()