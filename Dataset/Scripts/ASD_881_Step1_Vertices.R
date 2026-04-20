#Script to build/update Master Vertices

#Set the name of the polygon
pName="88.1"

#Set the name of this script
sName="ASD_881_Step1_Vertices.R"



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
#First inland vertex of the western boundary
tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P1"],PV$Latitude[PV$Vertex=="P1"],
                               PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"]),
                       Line2=c(IV$Longitude[IV$Vertex=="I95"],IV$Latitude[IV$Vertex=="I95"],
                               IV$Longitude[IV$Vertex=="I96"],IV$Latitude[IV$Vertex=="I96"]),Plot=F)
tmp=round(tmp,2)
SVtmp=data.frame(
  Latitude=as.numeric(tmp['Lat']),
  Longitude=as.numeric(tmp['Lon']),
  Vertex="S17"
)

#S18: New SV to mark antimeridian crossing @60S
tmp=data.frame(
  Latitude=-60,
  Longitude=179.999999,
  Vertex="S18"
)
SVtmp=rbind(SVtmp,tmp)

#S19: New SV to mark antimeridian crossing @60S
tmp=data.frame(
  Latitude=-60,
  Longitude=-179.999999,
  Vertex="S19"
)
SVtmp=rbind(SVtmp,tmp)

#Second inland vertex of the eastern boundary
tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"],
                               PV$Longitude[PV$Vertex=="P4"],PV$Latitude[PV$Vertex=="P4"]),
                       Line2=c(IV$Longitude[IV$Vertex=="I114"],IV$Latitude[IV$Vertex=="I114"],
                               IV$Longitude[IV$Vertex=="I115"],IV$Latitude[IV$Vertex=="I115"]),Plot=F)
tmp=round(tmp,2)
tmp=data.frame(
  Latitude=as.numeric(tmp['Lat']),
  Longitude=as.numeric(tmp['Lon']),
  Vertex="S20"
)
SVtmp=rbind(SVtmp,tmp)

#S21 & S22: New SVs to mark antimeridian crossing, inland, @60S (NB the +360 on negative lon)
tmp=get_C_intersection(Line1=c(180,-90,
                               180,0),
                       Line2=c(IV$Longitude[IV$Vertex=="I113"],IV$Latitude[IV$Vertex=="I113"],
                               IV$Longitude[IV$Vertex=="I114"]+360,IV$Latitude[IV$Vertex=="I114"]),Plot=F)
tmp=round(tmp,2)
Latx=as.numeric(tmp['Lat'])

tmp=data.frame(
  Latitude=Latx,
  Longitude=-179.999999,
  Vertex="S21"
)
SVtmp=rbind(SVtmp,tmp)

tmp=data.frame(
  Latitude=Latx,
  Longitude=179.999999,
  Vertex="S22"
)
SVtmp=rbind(SVtmp,tmp)
#Check identity
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}


#3. Build Master vertices and verify they are the same as loaded
MVtmp=bind_rows(
  SV[which(SV$Vertex=="S17"),(1:3)],
  PV[which(PV$Vertex=="P2"),(1:3)],
  SV[which(SV$Vertex=="S18"):which(SV$Vertex=="S19"),(1:3)],
  PV[which(PV$Vertex=="P3"),(1:3)],
  SV[which(SV$Vertex=="S20"),(1:3)],
  IV[which(IV$Vertex=="I114"),(1:3)],
  SV[which(SV$Vertex=="S21"):which(SV$Vertex=="S22"),(1:3)],
  IV[which(IV$Vertex=="I113"):which(IV$Vertex=="I96"),(1:3)]
)
MVtmp$Name=pName
#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()