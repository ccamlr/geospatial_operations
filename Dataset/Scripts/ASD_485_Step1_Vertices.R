#Script to build/update Master Vertices

#Set the name of the polygon
pName="48.5"

#Set the name of this script
sName="ASD_485_Step1_Vertices.R"



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
#Mark 48.2/4 corners
SVtmp=data.frame(
  Latitude=-64,
  Longitude=-30,
  Vertex="S9"
)

tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P4"],PV$Latitude[PV$Vertex=="P4"],
                               PV$Longitude[PV$Vertex=="P5"],PV$Latitude[PV$Vertex=="P5"]),
                       Line2=c(IV$Longitude[IV$Vertex=="I34"],IV$Latitude[IV$Vertex=="I34"],
                               IV$Longitude[IV$Vertex=="I35"],IV$Latitude[IV$Vertex=="I35"]),Plot=F)
tmp=round(tmp,2)
tmp=data.frame(
  Latitude=as.numeric(tmp['Lat']),
  Longitude=as.numeric(tmp['Lon']),
  Vertex="S10"
)
SVtmp=rbind(SVtmp,tmp)
#Check identity
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}


#3. Build Master vertices and verify they are the same as loaded
MVtmp=bind_rows(
  SV[which(SV$Vertex=="S7"),(1:3)],
  PV[which(PV$Vertex=="P2"):which(PV$Vertex=="P3"),(1:3)],
  SV[which(SV$Vertex=="S9"),(1:3)],
  PV[which(PV$Vertex=="P4"),(1:3)],
  SV[which(SV$Vertex=="S10"),(1:3)],
  IV[which(IV$Vertex=="I34"):which(IV$Vertex=="I2"),(1:3)]
)
MVtmp$Name=pName
#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()