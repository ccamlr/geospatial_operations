#Script to build/update Master Vertices

#Set the name of the polygon
pName="1"

#Set the name of this script
sName="PD_1_Step1_Vertices.R"



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
tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P6"],PV$Latitude[PV$Vertex=="P6"],
                               PV$Longitude[PV$Vertex=="P7"],PV$Latitude[PV$Vertex=="P7"]),
                       Line2=c(IV$Longitude[IV$Vertex=="I1"],IV$Latitude[IV$Vertex=="I1"],
                               IV$Longitude[IV$Vertex=="I2"],IV$Latitude[IV$Vertex=="I2"]),Plot=F)
tmp=round(tmp,2)
SVtmp=data.frame(
  Latitude=as.numeric(tmp['Lat']),
  Longitude=as.numeric(tmp['Lon']),
  Vertex="S84"
)
#Etc...

#Check identity between SVtmp and the existing SV.
if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}


#3. Build Master vertices (turn your vertices plan into code)
MVtmp=bind_rows(
  PV[which(PV$Vertex=="P2"),(1:3)],
  SV[which(SV$Vertex=="S52"),(1:3)],
  PV[which(PV$Vertex=="P3"):which(PV$Vertex=="P6"),(1:3)],
  SV[which(SV$Vertex=="S6"),(1:3)],
  SV[which(SV$Vertex=="S84"),(1:3)],
  IV[which(IV$Vertex=="I2"):which(IV$Vertex=="I6"),(1:3)],
  IV[which(IV$Vertex=="I143"):which(IV$Vertex=="I138"),(1:3)],
  SV[which(SV$Vertex=="S79"),(1:3)]
)
MVtmp$Name=pName
# write.csv(MVtmp,paste0(Root,"/Inputs/tmp.csv"),row.names=F)
# qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green")


#Check identity between MVtmp and the existing MV.
if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}

message(paste0(sName," done."))
gc()