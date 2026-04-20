#Script to create/check master dataset of inland vertices
library(CCAMLRGIS)
library(dplyr)

#Get coastline
coast=load_Coastline()
coast=coast[coast$surface=="Land",]

#Get vertices
Vs=read.csv("Inland_Vertices_V2.csv")

#Build points and polygon
Ps=create_Points(Input=Vs[,c(2,3,1)])
Vs=rbind(Vs,Vs[8,])
Ls=create_Lines(Input=data.frame(n=1,Vs$Latitude,Vs$Longitude),Densify = T)

png(filename='Master_IV_Check1.png',width=10000,height=10000,res=300)

par(mai=rep(0,4),xaxs="i",yaxs="i")
plot(st_geometry(coast),col='grey',border=NA,
     xlim=c(-2700000,2500000),ylim=c(-2500000,3000000),xpd=T)
plot(st_geometry(Ls),add=T,lwd=1.5,col="red")
plot(st_geometry(Ps),add=T,pch=4,cex=1.5,lwd=1.5,col="red")
text(Ps$x,Ps$y,Ps$Vertex,adj=c(1,0.5),col="red",xpd=T,cex=2)

dev.off()

png(filename='Master_IV_Check2.png',width=10000,height=10000,res=300)

par(mai=rep(0,4),xaxs="i",yaxs="i")
plot(st_geometry(coast),col='grey',border=NA,
     xlim=c(-2700000,-2000000),ylim=c(200000,2200000),xpd=T)
plot(st_geometry(Ls),add=T,lwd=1.5,col="red")
plot(st_geometry(Ps),add=T,pch=4,cex=1.5,lwd=1.5,col="red")
text(Ps$x,Ps$y,Ps$Vertex,adj=c(1,0.5),col="red",xpd=T,cex=4)

dev.off()

png(filename='Master_IV_Check3.png',width=10000,height=10000,res=300)

par(mai=rep(0,4),xaxs="i",yaxs="i")
plot(st_geometry(coast),col='grey',border=NA,
     xlim=c(-2500000,-1700000),ylim=c(800000,1650000),xpd=T)
plot(st_geometry(Ls),add=T,lwd=1.5,col="red")
plot(st_geometry(Ps),add=T,pch=4,cex=1.5,lwd=1.5,col="red")
text(Ps$x,Ps$y,Ps$Vertex,adj=c(1,0.5),col="red",xpd=T,cex=4)

dev.off()




#Get inland buffer of continent
Land=st_cast(coast,"POLYGON")
Ars=as.numeric(st_area(Land))

plot(st_geometry(Land))
plot(st_geometry(Land[Ars==max(Ars),]),add=T,col='grey')

#Isolate continent
Land=Land[Ars==max(Ars),]



#Buffer and simplify, then isolate
Buf=-50000
Tol=25000

par(mai=rep(0,4),xaxs="i",yaxs="i")
plot(st_geometry(Land))
plot(st_simplify(st_buffer(Land,dist=Buf),
                 preserveTopology = T,
                 dTolerance = Tol),add=T,border="red")

InL=st_simplify(st_buffer(Land,dist=Buf),
                preserveTopology = T,
                dTolerance = Tol)

InL=st_cast(InL,"POLYGON")
Ars=as.numeric(st_area(InL))

plot(st_geometry(InL))
plot(st_geometry(InL[Ars==max(Ars),]),add=T,col='grey')

#Isolate continent
InL=InL[Ars==max(Ars),]

#Extract coordinate, then back-project, then add Peninsula points
Coo=st_coordinates(InL)
Coo=data.frame(Y=Coo[,2],X=Coo[,1])
Coo=project_data(Coo,inv=T,append = F,NamesIn=c('Y','X'),NamesOut=c("Latitude","Longitude"))

Coo=distinct(Coo)
Coo=data.frame(
  Latitude=round(Coo$Latitude,2),
  Longitude=round(Coo$Longitude,2),
  Vertex=seq(1,nrow(Coo))
)

Penin=data.frame(
  Latitude=c(-63.25,-64.7,-65.5,-67,-68),
  Longitude=c(-57.2,-61.5,-63.4,-65.7,-66.2),
  Vertex=seq(1,5)
)
Ps_3=create_Points(Input=Penin)

Ps_2=create_Points(Input=Coo)

Vs_2=rbind(Coo,Coo[1,])

Ls_2=create_Lines(Input=data.frame(n=1,Vs_2$Latitude,Vs_2$Longitude),Densify = T)


png(filename='Master_IV_Check4.png',width=10000,height=10000,res=300)

par(mai=rep(0,4),xaxs="i",yaxs="i")
plot(st_geometry(coast),col='grey',border=NA,
     xlim=c(-2700000,2500000),ylim=c(-2500000,3000000),xpd=T)
plot(st_geometry(Ls_2),add=T,lwd=1.5,col="red")
plot(st_geometry(Ps_2),add=T,pch=4,cex=1.5,lwd=1.5,col="red")
plot(st_geometry(Ps_3),add=T,pch=4,cex=1.5,lwd=1.5,col="darkgreen")
text(Ps_2$x,Ps_2$y,Ps_2$Vertex,adj=c(1,0.5),col="red",xpd=T,cex=2)

dev.off()


#Final set of vertices
Vs_F=rbind(Penin,Coo)
Vs_F$Vertex=seq(1,nrow(Vs_F))

Ps_F=create_Points(Vs_F)

Vs_F=rbind(Vs_F,Vs_F[6,])

Ls_F=create_Lines(Input=data.frame(n=1,Vs_F$Latitude,Vs_F$Longitude),Densify = T)


png(filename='Master_IV_Check6.png',width=10000,height=10000,res=300)

par(mai=rep(0,4),xaxs="i",yaxs="i")
plot(st_geometry(coast),col='grey',border=NA,
     xlim=c(-2700000,2500000),ylim=c(-2500000,3000000),xpd=T)
plot(st_geometry(Ls_F),add=T,lwd=1.5,col="red")
plot(st_geometry(Ps_F),add=T,pch=4,cex=1,lwd=1,col="red")
text(Ps_F$x,Ps_F$y,Ps_F$Vertex,adj=c(1,0.5),col="darkgreen",xpd=T,cex=2)

dev.off()

#Export final set of vertices
write.csv(Vs_F,"Inland_Vertices_V3.csv",row.names = F)
