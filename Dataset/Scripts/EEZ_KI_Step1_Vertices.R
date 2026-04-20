#Script to build/update Master Vertices

#Set the name of the polygon
pName="KI"

#Set the name of this script
sName="EEZ_KI_Step1_Vertices.R"



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
  PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P271"),(1:3)],
  SV[which(SV$Vertex=="S42"):which(SV$Vertex=="S36"),(1:3)]
 )
MVtmp$Name=pName
# write.csv(MVtmp,paste0(Root,"/Inputs/tmp.csv"),row.names=F)
# qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green")
# st_is_valid(qq)

#Check identity between MVtmp and the existing MV.
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()