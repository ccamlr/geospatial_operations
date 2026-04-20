#Script to build/update Master Vertices

#Set the name of the polygon
pName="APE"

#Set the name of this script
sName="SSMU_APE_Step1_Vertices.R"



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
SVtmp=data.frame(
  Latitude=c(-65.97,-66.01,-66.07,-66.12,-66.17,-66),
  Longitude=c(-60.67,-60.95,-61.07,-61.29,-61.94,-62.55),
  Vertex=paste0("S",seq(94,99))
)


#Check identity between SVtmp and the existing SV.
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}

#3. Build Master vertices (turn your vertices plan into code)
MVtmp=bind_rows(
  PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P87"),(1:3)],
  SV[which(SV$Vertex=="S94"):which(SV$Vertex=="S99"),(1:3)],
  SV[which(SV$Vertex=="S92"),(1:3)],
  IV[which(IV$Vertex=="I3"):which(IV$Vertex=="I2"),(1:3)],
  SV[which(SV$Vertex=="S91"),(1:3)],
  SV[which(SV$Vertex=="S93"),(1:3)],
  IV[which(IV$Vertex=="I1"),(1:3)]
)
MVtmp$Name=pName
# write.csv(MVtmp,paste0(Root,"/Inputs/tmp.csv"),row.names=F) #Copy/paste this into Master Vertices, then re-run from top
# qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green")
# st_is_valid(qq)

#Check identity between MVtmp and the existing MV.
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()