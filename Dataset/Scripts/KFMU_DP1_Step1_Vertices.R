#Script to build/update Master Vertices

#Set the name of the polygon
pName="DP1"

#Set the name of this script
sName="KFMU_DP1_Step1_Vertices.R"


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
tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P1"],PV$Latitude[PV$Vertex=="P1"],
                               PV$Longitude[PV$Vertex=="P5"],PV$Latitude[PV$Vertex=="P5"]),
                       Line2=c(IV$Longitude[IV$Vertex=="I3"],IV$Latitude[IV$Vertex=="I3"],
                               IV$Longitude[IV$Vertex=="I4"],IV$Latitude[IV$Vertex=="I4"]),Plot=F)
tmp=round(tmp,2)
SVtmp=data.frame(
  Latitude=as.numeric(tmp['Lat']),
  Longitude=as.numeric(tmp['Lon']),
  Vertex="S101"
)


#Check identity between SVtmp and the existing SV.
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}

#3. Build Master vertices (turn your vertices plan into code)
MVtmp=bind_rows(
  SV[which(SV$Vertex=="S101"),(1:3)],
  SV[which(SV$Vertex=="S92"),(1:3)],
  IV[which(IV$Vertex=="I4"),(1:3)],
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