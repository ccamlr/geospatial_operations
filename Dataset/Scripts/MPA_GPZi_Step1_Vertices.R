#Script to build/update Master Vertices

#Set the name of the polygon
pName="GPZi"

#Set the name of this script
sName="MPA_GPZi_Step1_Vertices.R"


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

#S68
#P2-P6
#S90
#P7-P13
#S71
#I124-I114
#S21-S22
#I113-I98

#3. Build Master vertices (turn your vertices plan into code)
MVtmp=bind_rows(
  SV[which(SV$Vertex=="S68"),(1:3)],
  PV[which(PV$Vertex=="P2"):which(PV$Vertex=="P6"),(1:3)],
  SV[which(SV$Vertex=="S90"),(1:3)],
  PV[which(PV$Vertex=="P7"):which(PV$Vertex=="P13"),(1:3)],
  SV[which(SV$Vertex=="S71"),(1:3)],
  IV[which(IV$Vertex=="I124"):which(IV$Vertex=="I114"),(1:3)],
  SV[which(SV$Vertex=="S21"):which(SV$Vertex=="S22"),(1:3)],
  IV[which(IV$Vertex=="I113"):which(IV$Vertex=="I98"),(1:3)]
)
MVtmp$Name=pName
# write.csv(MVtmp,paste0(Root,"/Inputs/tmp.csv"),row.names=F)
# qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green")


#Check identity between MVtmp and the existing MV.
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()