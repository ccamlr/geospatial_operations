#Script to work on draft polygon, before moving to official datasets and scripts
library(CCAMLRGIS)
library(dplyr)
ASDs=load_ASDs()
SSRUs=load_SSRUs()

setwd("I:/Science/Projects/Geospatial Operations/GIS Workflow/Polygon Builder/In Progress")


#Set the name of the polygon
pName="SSRUs"

tmp=read.csv("I:/Science/Projects/Geospatial Operations/GIS Workflow/Polygon Builder/Primary Vertices/SSRUVs.csv")
tmp$Latitude[tmp$Latitude==-89]=-84
tmpP=create_Polys(tmp)

png(filename=paste0("Temp_",pName,"_01.png"),width=5000,height=5000,res=600)
par(mai=rep(0.1,4),xaxs='i',yaxs="i",xpd=T)
plot(st_geometry(SSRUs),lwd=3)
add_labels(mode='auto',layer='SSRUs',fontsize=0.2)
plot(st_geometry(tmpP),border="red",add=T)
text(tmpP$Labx,tmpP$Laby,tmpP$ID,col="red",cex=0.2)
plot(st_geometry(tmpP[tmpP$ID=="5844aB",]),border="green",add=T)
dev.off()


# i=14
# Ps=create_Points(tmp[tmp$SSRU==tmpP$ID[i],2:3])
# par(mai=rep(0.2,4),xaxs='i',yaxs="i",xpd=T)
# plot(st_geometry(tmpP[i,]),border="red")
# plot(st_geometry(SSRUs),lwd=3,add=T)
# add_labels(mode='auto',layer='SSRUs')
# plot(st_geometry(tmpP[i,]),border="red",add=T)
# text(tmpP$Labx[i],tmpP$Laby[i],tmpP$ID[i],col="red",cex=0.2)
# text(Ps$x,Ps$y,Ps$ID,col="green",cex=3)
# i=i+1

tmp=arrange(tmp,SSRU)
colnames(tmp)=c("Name","Latitude","Longitude")
tmp$Vertex=NA

for(n in sort(unique(tmp$Name))){
  indx=which(tmp$Name==n)
  tmp$Vertex[indx]=paste0("P",seq(1,length(indx)))
}

tmp=tmp[,c("Latitude","Longitude","Vertex","Name")]

write.csv(tmp,"SSRUs_Clean.csv",row.names = F)


# OK, now the input is clean.


ssru_id=pName

#Use same names as final scripts to facilitate copy/paste
#PV Primary Vertices
#IV Inland Vertices
#SV Secondary Vertices
#MV Master Vertices
#Load temporary primary vertices
PV=read.csv("Temp_PVertices.csv")
PV=PV%>%filter(Name==ssru_id)
Pps=create_Points(PV)
Pls=create_Lines(Input=data.frame(n=1,PV$Latitude,PV$Longitude),Densify = T)

#Load Existing inland vertices
IV=read.csv("I:/Science/Projects/Geospatial Operations/GIS Workflow/Polygon Builder/Master Inland Vertices/Inland_Vertices_V3.csv",check.names = F)
Ips=create_Points(IV)
Ils=suppressWarnings(create_Lines(Input=data.frame(n=1,
                                                   c(IV$Latitude,IV$Latitude[6]),
                                                   c(IV$Longitude,IV$Longitude[6])
),Densify = T))

#Load Existing Secondary vertices
SV=read.csv("I:/Science/Projects/Geospatial Operations/GIS Workflow/Polygon Builder/Secondary Vertices/Secondary_Vertices.csv",check.names = F)
Sps=create_Points(SV)
message(paste0("The last existing Secondary Vertex is: ",SV$Vertex[nrow(SV)]))



#Plot 01
png(filename=paste0("Temp_",ssru_id,"_01.png"),width=5000,height=5000,res=600)

par(mai=c(0.3,0.3,0.3,0.3),xaxs="i",yaxs="i",xpd=T)
plot(st_geometry(Pps),lwd=0.1,col="white")
plot(st_geometry(ASDs),add=T,col="grey95",lwd=0.1)
plot(st_geometry(Coast[Coast$ID=='All',]),col='grey',border=NA,xpd=T,add=T)

plot(st_geometry(Ils),add=T,lwd=1,col="red")
plot(st_geometry(Ips),add=T,pch=4,cex=0.5,col="red")
text(Ips$x,Ips$y,Ips$Vertex,adj=c(1.2,0.5),col="red",xpd=T,cex=0.5)

plot(st_geometry(Pls),add=T,lwd=1,col="darkgreen")
plot(st_geometry(Pps),add=T,pch=4,cex=0.5,col="darkgreen")
text(Pps$x,Pps$y,Pps$Vertex,adj=c(1.2,0.5),col="darkgreen",xpd=T,cex=1)

plot(st_geometry(Sps),add=T,pch=4,cex=0.5,col="blue")
text(Sps$x,Sps$y,Sps$Vertex,adj=c(-0.2,0.5),col="blue",xpd=T,cex=0.5)

dev.off()


#Describe the plan:
#P1
#S15-S16
#P2-P3
#S48-S49
#P4
#S50
#P5
#S51
#P6-P7
#S18-S19
#S24-S25
#S52: New SV to mark corner of 88.3/48.1
#P8
#S14




#Drafts SVs for copy/paste
# Sxx: Inland vertex for east/western boundary: Px-Py and Ix-Iy intersection
# tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"],
#                                PV$Longitude[PV$Vertex=="P4"],PV$Latitude[PV$Vertex=="P4"]),
#                        Line2=c(IV$Longitude[IV$Vertex=="I132"],IV$Latitude[IV$Vertex=="I132"],
#                                IV$Longitude[IV$Vertex=="I133"],IV$Latitude[IV$Vertex=="I133"]),Plot=F)
# tmp=round(tmp,2)
# SVtmp=data.frame(
#   Latitude=as.numeric(tmp['Lat']),
#   Longitude=as.numeric(tmp['Lon']),
#   Vertex="S23"
# )
#
# Sxx: New SV to mark corner of YYZZ
# tmp=data.frame(
#   Latitude=-60,
#   Longitude=-105,
#   Vertex="S25"
# )
#
#
# SVtmp=rbind(SVtmp,tmp)




#Create Secondary vertices

#S52: New SV to mark corner of 88.3/48.1
SVtmp=data.frame(
  Latitude=-60,
  Longitude=-70,
  Vertex="S52"
)



#Check identity



write.csv(SVtmp,"Temp_SVertices.csv");SV=rbind(SV,SVtmp)#this line is only for the InProgress code!!!!!!!!!!!!!
if(length(unique(SV$Vertex))!=nrow(SV)){stop("Duplicated SV Vertex name")}


#Build Master vertices and verify they are the same as loaded

# #Either easy polygon:
# MVtmp=PV



#Or complex one
MVtmp=bind_rows(
  PV[which(PV$Vertex=="P1"),(1:3)],
  SV[which(SV$Vertex=="S15"):which(SV$Vertex=="S16"),(1:3)],
  PV[which(PV$Vertex=="P2"):which(PV$Vertex=="P3"),(1:3)],
  SV[which(SV$Vertex=="S48"):which(SV$Vertex=="S49"),(1:3)],
  PV[which(PV$Vertex=="P4"),(1:3)],
  SV[which(SV$Vertex=="S50"),(1:3)],
  PV[which(PV$Vertex=="P5"),(1:3)],
  SV[which(SV$Vertex=="S51"),(1:3)],
  PV[which(PV$Vertex=="P6"):which(PV$Vertex=="P7"),(1:3)],
  SV[which(SV$Vertex=="S18"):which(SV$Vertex=="S19"),(1:3)],
  SV[which(SV$Vertex=="S24"):which(SV$Vertex=="S25"),(1:3)],
  SV[which(SV$Vertex=="S52"),(1:3)],
  PV[which(PV$Vertex=="P8"),(1:3)],
  SV[which(SV$Vertex=="S14"),(1:3)]
)
MVtmp$Name=pName
#Check identity



#S52: New SV to mark corner of 88.3/48.1
#P8
#S14


# #Add Antimeridian
# AM=create_Lines(Input=data.frame(n=1,
#                                   c(0,-87),
#                                   c(180,180)
# ),Densify = T)

write.csv(MVtmp,"Temp_MVertices.csv")#this line is only for the InProgress code!!!!!!!!!!!!!


Mps=create_Points(MVtmp)

#Plot 02
png(filename=paste0("Temp_",pName,"_02.png"),width=5000,height=5000,res=600)

par(mai=c(0.3,0.3,0.3,0.3),xaxs="i",yaxs="i",xpd=T)
plot(st_geometry(Pps),lwd=0.1,col="white")
plot(st_geometry(ASDs),add=T,col="grey95",lwd=0.1)
plot(st_geometry(Coast[Coast$ID=='All',]),col='grey',border=NA,xpd=T,add=T)

# plot(st_geometry(AM),add=T,lwd=1,col="yellow")

plot(st_geometry(Ils),add=T,lwd=1,col="red")
plot(st_geometry(Ips),add=T,pch=4,cex=0.5,col="red")
text(Ips$x,Ips$y,Ips$Vertex,adj=c(1.2,0.5),col="red",xpd=T,cex=1)

plot(st_geometry(Pls),add=T,lwd=1,col="darkgreen")
plot(st_geometry(Pps),add=T,pch=4,cex=0.5,col="darkgreen")
text(Pps$x,Pps$y,Pps$Vertex,adj=c(1.2,0.5),col="darkgreen",xpd=T,cex=1)

plot(st_geometry(Sps),add=T,pch=4,cex=0.5,col="blue")
text(Sps$x,Sps$y,Sps$Vertex,adj=c(-0.2,0.5),col="blue",xpd=T,cex=0.5)

plot(st_geometry(Mps),add=T,pch=4,cex=0.5,col="orange")
text(Mps$x,Mps$y,Mps$Vertex,adj=c(1.2,0.5),col="orange",xpd=T,cex=1)

dev.off()

#Once done, copy the vertices from the Temp_ csv files into the final csv files
#And copy the codes where they belong.