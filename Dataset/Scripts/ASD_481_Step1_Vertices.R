#Script to build/update Master Vertices

#Set the name of the polygon
pName="48.1"

#Set the name of this script
sName="ASD_481_Step1_Vertices.R"



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
#2.1. First inland vertex of the western boundary
tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P1"],PV$Latitude[PV$Vertex=="P1"],
                               PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"]),
                       Line2=c(IV$Longitude[IV$Vertex=="I140"],IV$Latitude[IV$Vertex=="I140"],
                               IV$Longitude[IV$Vertex=="I141"],IV$Latitude[IV$Vertex=="I141"]),Plot=F)
tmp=round(tmp,2)
SVtmp=data.frame(
  Latitude=as.numeric(tmp['Lat']),
  Longitude=as.numeric(tmp['Lon']),
  Vertex="S1"
)
#2.2. Alexander Island vertices
tmp=data.frame(
  Latitude=c(-71,-70.9,-70.3,-70.2),
  Longitude=c(-70,-69.5,-69.5,-70),
  Vertex=c("S2","S3","S4","S5")
)
SVtmp=rbind(SVtmp,tmp)
#2.3. Subarea 48.2 edge extremity
tmp=data.frame(
  Latitude=-64,
  Longitude=-50,
  Vertex="S6"
)
SVtmp=rbind(SVtmp,tmp)
#2.4. Eastern Peninsula landing
tmp=data.frame(
  Latitude=-65,
  Longitude=-61.07,
  Vertex="S7"
)
SVtmp=rbind(SVtmp,tmp)
#Check identity
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}


#3. Build Master vertices and verify they are the same as loaded
MVtmp=bind_rows(
  SV[which(SV$Vertex=="S1"):which(SV$Vertex=="S5"),(1:3)],
  PV[which(PV$Vertex=="P2"):which(PV$Vertex=="P3"),(1:3)],
  SV[which(SV$Vertex=="S6"),(1:3)],
  PV[which(PV$Vertex=="P4"),(1:3)],
  SV[which(SV$Vertex=="S7"),(1:3)],
  IV[which(IV$Vertex=="I2"):which(IV$Vertex=="I6"),(1:3)],
  IV[which(IV$Vertex=="I143"):which(IV$Vertex=="I141"),(1:3)]
)
MVtmp$Name=pName
#Check identity
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()