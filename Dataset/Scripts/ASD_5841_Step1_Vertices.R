#Script to build/update Master Vertices

#Set the name of the polygon
pName="58.4.1"

#Set the name of this script
sName="ASD_5841_Step1_Vertices.R"



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
#S26: Inland vertex for western boundary: P1-P2 and I74-I75 intersection
tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P1"],PV$Latitude[PV$Vertex=="P1"],
                               PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"]),
                       Line2=c(IV$Longitude[IV$Vertex=="I74"],IV$Latitude[IV$Vertex=="I74"],
                               IV$Longitude[IV$Vertex=="I75"],IV$Latitude[IV$Vertex=="I75"]),Plot=F)
tmp=round(tmp,2)
SVtmp=data.frame(
  Latitude=as.numeric(tmp['Lat']),
  Longitude=as.numeric(tmp['Lon']),
  Vertex="S26"
)

# S27: New SV to mark corner of 88.1
tmp=data.frame(
  Latitude=-60,
  Longitude=150,
  Vertex="S27"
)

SVtmp=rbind(SVtmp,tmp)
#Check identity
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}


#3. Build Master vertices and verify they are the same as loaded
MVtmp=bind_rows(
  SV[which(SV$Vertex=="S26"),(1:3)],
  PV[which(PV$Vertex=="P2"):which(PV$Vertex=="P5"),(1:3)],
  SV[which(SV$Vertex=="S27"),(1:3)],
  SV[which(SV$Vertex=="S17"),(1:3)],
  IV[which(IV$Vertex=="I95"):which(IV$Vertex=="I75"),(1:3)]
)
MVtmp$Name=pName
#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()