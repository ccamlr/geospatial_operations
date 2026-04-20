#Script to build/update Master Vertices

#Set the name of the polygon
pName="48.6"

#Set the name of this script
sName="ASD_486_Step1_Vertices.R"



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
#Mark 48.4/5 corners
SVtmp=data.frame(
  Latitude=-64,
  Longitude=-20,
  Vertex="S11"
)

#Mark 58.4.2/4a corners
tmp=data.frame(
  Latitude=-62,
  Longitude=30,
  Vertex="S12"
)
SVtmp=rbind(SVtmp,tmp)

#Intersection between P3-P4 and I49-I50
tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"],
                               PV$Longitude[PV$Vertex=="P4"],PV$Latitude[PV$Vertex=="P4"]),
                       Line2=c(IV$Longitude[IV$Vertex=="I49"],IV$Latitude[IV$Vertex=="I49"],
                               IV$Longitude[IV$Vertex=="I50"],IV$Latitude[IV$Vertex=="I50"]),Plot=F)
tmp=round(tmp,2)
tmp=data.frame(
  Latitude=as.numeric(tmp['Lat']),
  Longitude=as.numeric(tmp['Lon']),
  Vertex="S13"
)
SVtmp=rbind(SVtmp,tmp)
#Check identity
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}


#3. Build Master vertices and verify they are the same as loaded
MVtmp=bind_rows(
  SV[which(SV$Vertex=="S10"):which(SV$Vertex=="S11"),(1:3)],
  PV[which(PV$Vertex=="P2"):which(PV$Vertex=="P3"),(1:3)],
  SV[which(SV$Vertex=="S12"):which(SV$Vertex=="S13"),(1:3)],
  IV[which(IV$Vertex=="I49"):which(IV$Vertex=="I35"),(1:3)]
)
MVtmp$Name=pName
#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()