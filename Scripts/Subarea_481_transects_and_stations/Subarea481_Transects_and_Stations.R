#Script to build transects as requested by WG-ASAM-24
library(CCAMLRGIS)
library(terra)
coast=load_Coastline()
ASDs=load_ASDs()
ASDs=ASDs[ASDs$GAR_Short_Label=="481",]
SOA=st_read("I:/Science/Team/Stephane/For Vicky/02/Proposed_Krill_MUs.shp",quiet=T)

PathToBathy="I:/Science/Projects/GEBCO/2023/Processed/GEBCO2023_500.tif" #Use the Load_Bathy() function to get this
Bathy=rast(PathToBathy)


Ts=read.csv("ASAM-24-Transects.csv")
#Build points to mark start(green) and end(red)
Ps=create_Points(Ts[,c("latitude","longitude","type")])

#Build projected lines
Tsp=create_Lines(Ts[,c("transect_name","latitude","longitude")],Densify = T)

#Get Stations
St20=read.csv("ASAM-24-Stations-20Nm-max.csv")
St20p=create_Points(St20[,c("Latitude","Longitude","ID")])
St30=read.csv("ASAM-24-Stations-30Nm-max.csv")
St30p=create_Points(St30[,c("Latitude","Longitude","ID")])
St40=read.csv("ASAM-24-Stations-40Nm-max.csv")
St40p=create_Points(St40[,c("Latitude","Longitude","ID")])
St20_30=read.csv("ASAM-24-Stations-20and30Nm-max.csv")
St20_30p=create_Points(St20_30[,c("Latitude","Longitude","ID")])
St20_40=read.csv("ASAM-24-Stations-20and40Nm-max.csv")
St20_40p=create_Points(St20_40[,c("Latitude","Longitude","ID")])



#Extract MU labels 
Labs=st_drop_geometry(SOA[,c("id","labx","laby")])
Labs=project_data(Labs,NamesIn=c("laby","labx"),inv=T)
Labs=create_Points(Labs[,c("Latitude","Longitude","id")])

#Rotate objects
Lonzero=-60 #This longitude will point up
R_SOA=Rotate_obj(SOA,Lonzero)
R_coast=Rotate_obj(coast,Lonzero)
R_labs=Rotate_obj(Labs,Lonzero)
R_labs$x=st_coordinates(R_labs)[,1]
R_labs$y=st_coordinates(R_labs)[,2]
R_Tsp=Rotate_obj(Tsp,Lonzero)
R_bathy=Rotate_obj(Bathy,Lonzero)
R_Ps=Rotate_obj(Ps,Lonzero)
R_St20=Rotate_obj(St20p,Lonzero)
R_St30=Rotate_obj(St30p,Lonzero)
R_St40=Rotate_obj(St40p,Lonzero)
R_St20_30=Rotate_obj(St20_30p,Lonzero)
R_St20_40=Rotate_obj(St20_40p,Lonzero)

#Get midpoints to add labels
Mp=suppressWarnings( st_centroid(R_Tsp) )
Mp=st_coordinates(Mp)
Tsp$Xmid=Mp[,1]
Tsp$Ymid=Mp[,2]
rm(Mp)

#Create a bounding box for the region
bb=st_bbox(st_buffer(R_SOA,20000)) #Get bounding box (x/y limits) + buffer
bx=st_as_sfc(bb) #Build spatial box to plot

#Use spatial box to crop coastline
R_coast=suppressWarnings(st_intersection(R_coast,bx))
R_bathy=crop(R_bathy,ext(bb))

#Adjust labels
R_labs$y[R_labs$id=="DP1"]=2800000
# R_labs$y[R_labs$id=="PB2"]=2850000
R_labs$y[R_labs$id=="JOIN"]=3000000
R_labs$y[R_labs$id=="BS"]=2980000

#Plot
png(filename="ASAM-2024-Transects.png",width=2700,height=3000,res=600)
par(mai=rep(0.2,4))
plot(bx,lwd=0.1,xpd=T)
plot(R_bathy,breaks=Depth_cuts,col=Depth_cols,legend=FALSE,axes=FALSE,mar=NA,maxcell=5e6)
plot(st_geometry(R_coast[R_coast$surface=="Ice",]),col="white",lwd=0.5,add=T)
plot(st_geometry(R_SOA),border="black",lwd=1,add=T)
plot(st_geometry(R_coast[R_coast$surface=="Land",]),col="grey",add=T)
plot(st_geometry(R_Tsp),col="red",lwd=2,add=T)
add_RefGrid(bb=bb,ResLat = 2.5,ResLon = 5,lwd=0.5,fontsize = 0.5)
plot(bx,lwd=1,add=T,xpd=T)

text(Tsp$Xmid,Tsp$Ymid,Tsp$ID,cex=0.4)
text(R_labs$x,R_labs$y,R_labs$id,cex=0.5,font=2)

dev.off()


png(filename="ASAM-2024-Transects_start_end.png",width=2700,height=3000,res=600)
par(mai=rep(0.2,4))
plot(bx,lwd=0.1,xpd=T)
plot(R_bathy,breaks=Depth_cuts,col=Depth_cols,legend=FALSE,axes=FALSE,mar=NA,maxcell=5e6)
plot(st_geometry(R_coast[R_coast$surface=="Ice",]),col="white",lwd=0.5,add=T)
plot(st_geometry(R_SOA),border="black",lwd=1,add=T)
plot(st_geometry(R_coast[R_coast$surface=="Land",]),col="grey",add=T)
plot(st_geometry(R_Tsp),col="red",lwd=2,add=T)
add_RefGrid(bb=bb,ResLat = 2.5,ResLon = 5,lwd=0.5,fontsize = 0.5)
plot(bx,lwd=1,add=T,xpd=T)

plot(st_geometry(R_Ps[R_Ps$type=="start",]),add=T,pch=21,bg="green",cex=0.5,lwd=0.1)
plot(st_geometry(R_Ps[R_Ps$type=="end",]),add=T,pch=21,bg="red",cex=0.5,lwd=0.1)


text(Tsp$Xmid,Tsp$Ymid,Tsp$ID,cex=0.4)
text(R_labs$x,R_labs$y,R_labs$id,cex=0.5,font=2)

dev.off()


#Plot
png(filename="ASAM-2024-Stations_20Nm_Max.png",width=2700,height=3000,res=600)
par(mai=rep(0.2,4))
plot(bx,lwd=0.1,xpd=T)
plot(R_bathy,breaks=Depth_cuts,col=Depth_cols,legend=FALSE,axes=FALSE,mar=NA,maxcell=5e6)
plot(st_geometry(R_coast[R_coast$surface=="Ice",]),col="white",lwd=0.5,add=T)
plot(st_geometry(R_SOA),border="black",lwd=1,add=T)
plot(st_geometry(R_coast[R_coast$surface=="Land",]),col="grey",add=T)
plot(st_geometry(R_Tsp),col="red",lwd=2,add=T)
add_RefGrid(bb=bb,ResLat = 2.5,ResLon = 5,lwd=0.5,fontsize = 0.5)
plot(bx,lwd=1,add=T,xpd=T)

plot(st_geometry(R_St20),add=T,pch=21,bg="green",cex=0.5,lwd=0.1)


text(Tsp$Xmid,Tsp$Ymid,Tsp$ID,cex=0.4)
text(R_labs$x,R_labs$y,R_labs$id,cex=0.5,font=2)

dev.off()


#Plot
png(filename="ASAM-2024-Stations_30Nm_Max.png",width=2700,height=3000,res=600)
par(mai=rep(0.2,4))
plot(bx,lwd=0.1,xpd=T)
plot(R_bathy,breaks=Depth_cuts,col=Depth_cols,legend=FALSE,axes=FALSE,mar=NA,maxcell=5e6)
plot(st_geometry(R_coast[R_coast$surface=="Ice",]),col="white",lwd=0.5,add=T)
plot(st_geometry(R_SOA),border="black",lwd=1,add=T)
plot(st_geometry(R_coast[R_coast$surface=="Land",]),col="grey",add=T)
plot(st_geometry(R_Tsp),col="red",lwd=2,add=T)
add_RefGrid(bb=bb,ResLat = 2.5,ResLon = 5,lwd=0.5,fontsize = 0.5)
plot(bx,lwd=1,add=T,xpd=T)

plot(st_geometry(R_St30),add=T,pch=21,bg="green",cex=0.5,lwd=0.1)


text(Tsp$Xmid,Tsp$Ymid,Tsp$ID,cex=0.4)
text(R_labs$x,R_labs$y,R_labs$id,cex=0.5,font=2)

dev.off()


#Plot
png(filename="ASAM-2024-Stations_40Nm_Max.png",width=2700,height=3000,res=600)
par(mai=rep(0.2,4))
plot(bx,lwd=0.1,xpd=T)
plot(R_bathy,breaks=Depth_cuts,col=Depth_cols,legend=FALSE,axes=FALSE,mar=NA,maxcell=5e6)
plot(st_geometry(R_coast[R_coast$surface=="Ice",]),col="white",lwd=0.5,add=T)
plot(st_geometry(R_SOA),border="black",lwd=1,add=T)
plot(st_geometry(R_coast[R_coast$surface=="Land",]),col="grey",add=T)
plot(st_geometry(R_Tsp),col="red",lwd=2,add=T)
add_RefGrid(bb=bb,ResLat = 2.5,ResLon = 5,lwd=0.5,fontsize = 0.5)
plot(bx,lwd=1,add=T,xpd=T)

plot(st_geometry(R_St40),add=T,pch=21,bg="green",cex=0.5,lwd=0.1)


text(Tsp$Xmid,Tsp$Ymid,Tsp$ID,cex=0.4)
text(R_labs$x,R_labs$y,R_labs$id,cex=0.5,font=2)

dev.off()



png(filename="ASAM-2024-Stations_20and30Nm_Max.png",width=2700,height=3000,res=600)
par(mai=rep(0.2,4))
plot(bx,lwd=0.1,xpd=T)
plot(R_bathy,breaks=Depth_cuts,col=Depth_cols,legend=FALSE,axes=FALSE,mar=NA,maxcell=5e6)
plot(st_geometry(R_coast[R_coast$surface=="Ice",]),col="white",lwd=0.5,add=T)
plot(st_geometry(R_SOA),border="black",lwd=1,add=T)
plot(st_geometry(R_coast[R_coast$surface=="Land",]),col="grey",add=T)
plot(st_geometry(R_Tsp),col="red",lwd=2,add=T)
add_RefGrid(bb=bb,ResLat = 2.5,ResLon = 5,lwd=0.5,fontsize = 0.5)
plot(bx,lwd=1,add=T,xpd=T)

plot(st_geometry(R_St20_30),add=T,pch=21,bg="green",cex=0.5,lwd=0.1)


text(Tsp$Xmid,Tsp$Ymid,Tsp$ID,cex=0.4)
text(R_labs$x,R_labs$y,R_labs$id,cex=0.5,font=2)

dev.off()



png(filename="ASAM-2024-Stations_20and40Nm_Max.png",width=2700,height=3000,res=600)
par(mai=rep(0.2,4))
plot(bx,lwd=0.1,xpd=T)
plot(R_bathy,breaks=Depth_cuts,col=Depth_cols,legend=FALSE,axes=FALSE,mar=NA,maxcell=5e6)
plot(st_geometry(R_coast[R_coast$surface=="Ice",]),col="white",lwd=0.5,add=T)
plot(st_geometry(R_SOA),border="black",lwd=1,add=T)
plot(st_geometry(R_coast[R_coast$surface=="Land",]),col="grey",add=T)
plot(st_geometry(R_Tsp),col="red",lwd=2,add=T)
add_RefGrid(bb=bb,ResLat = 2.5,ResLon = 5,lwd=0.5,fontsize = 0.5)
plot(bx,lwd=1,add=T,xpd=T)

plot(st_geometry(R_St20_40),add=T,pch=21,bg="green",cex=0.5,lwd=0.1)


text(Tsp$Xmid,Tsp$Ymid,Tsp$ID,cex=0.4)
text(R_labs$x,R_labs$y,R_labs$id,cex=0.5,font=2)

dev.off()