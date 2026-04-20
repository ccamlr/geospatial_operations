#Script to work on draft polygon, before moving to official datasets and scripts
library(CCAMLRGIS)
library(dplyr)
ASDs=load_ASDs()
EEZs=load_EEZs()

coast=load_Coastline()
coast=coast[coast$surface=="Land",]
coast=st_union(coast)

#Set the name of the polygon
pName="SRZ"

#Use same names as final scripts to facilitate copy/paste
#PV Primary Vertices
#IV Inland Vertices
#SV Secondary Vertices
#MV Master Vertices
#Load temporary primary vertices
PV=read.csv("I:/Science/Projects/Geospatial Operations/GIS Workflow/Polygon Builder/In Progress/Temp_PVertices.csv")
Pps=create_Points(PV)
Pls=create_Lines(Input=data.frame(n=1,PV$Latitude,PV$Longitude),Densify = T)

#Load Existing inland vertices
IV=read.csv("I:/Science/Projects/Geospatial Operations/GIS Workflow/Polygon Builder/Inputs/Inland_Vertices_V3.csv",check.names = F)
Ips=create_Points(IV)
Ils=suppressWarnings(create_Lines(Input=data.frame(n=1,
                                                   c(IV$Latitude,IV$Latitude[6]),
                                                   c(IV$Longitude,IV$Longitude[6])
),Densify = T))

#Load Existing Secondary vertices
SV=read.csv("I:/Science/Projects/Geospatial Operations/GIS Workflow/Polygon Builder/Inputs/Secondary_Vertices.csv",check.names = F)
Sps=create_Points(SV)
message(paste0("The last existing Secondary Vertex is: ",SV$Vertex[nrow(SV)]))


# NewPs=data.frame(
#   Lat=c(-65.97,-66.01,-66.07,-66.12,-66.17,-66),
#   Lon=c(-60.67,-60.95,-61.07,-61.29,-61.94,-62.55)
# )
# NewPs=create_Points(NewPs)

#Plot
png(filename=paste0("I:/Science/Projects/Geospatial Operations/GIS Workflow/Polygon Builder/In Progress/InProgress_",pName,".png"),width=5000,height=5000,res=600)

par(mai=c(0.3,0.3,0.3,0.3),xaxs="i",yaxs="i",xpd=T)
plot(st_geometry(Pps),lwd=0.1,col="white")
# plot(st_geometry(Pps),lwd=0.1,col="white",xlim=c(-2500000,-2200000),ylim=c( 1200000,1300000 ))
plot(st_geometry(ASDs),add=T,col="grey95",lwd=0.1)
plot(st_geometry(coast),col='grey',border=NA,xpd=T,add=T)

plot(st_geometry(Ils),add=T,lwd=1,col="red")
plot(st_geometry(Ips),add=T,pch=4,cex=0.5,col="red")
text(Ips$x,Ips$y,Ips$Vertex,adj=c(1.2,0.5),col="red",xpd=T,cex=0.5)

plot(st_geometry(Pls),add=T,lwd=1,col="darkgreen")
plot(st_geometry(Pps),add=T,pch=4,cex=0.5,col="darkgreen")
text(Pps$x,Pps$y,Pps$Vertex,adj=c(1.2,0.5),col="darkgreen",xpd=T,cex=1)

plot(st_geometry(Sps),add=T,pch=4,cex=0.5,col="blue")
text(Sps$x,Sps$y,Sps$Vertex,adj=c(-0.2,0.5),col="blue",xpd=T,cex=0.5)

# plot(st_geometry(NewPs),add=T,pch=4,cex=0.5,col="orange")
# text(NewPs$x,NewPs$y,NewPs$ID,adj=c(-0.2,0.5),col="orange",xpd=T,cex=0.5)


dev.off()

