#Script to build proposed transects as developed by WG-ASAM-2024
library(CCAMLRGIS)
library(terra)

#Load coastline
coast=load_Coastline()
#Load candidate management units as proposed by WG-ASAM-2024/11 (Spatial Overlap Analysis)
SOA=st_read("Scripts/Subarea_481_transects_and_stations/Proposed_Krill_MUs_ASAM-2024_11.shp",quiet=T)

#Download bathymetry:
Bathy=load_Bathy(LocalFile=F,Res=1000) #Once downloaded, re-use it. See help(load_Bathy)
# Bathy=SmallBathy() #Use this instead for testing purposes first

#N.B. Below are commands to read csv inputs and build georeferenced datasets
#Users can instead read the shapefiles using sf::st_read()

#Get transects
Ts=read.csv("Scripts/Subarea_481_transects_and_stations/ASAM-24-Transects.csv")

#Build projected lines
Tsp=create_Lines(Ts[,c("transect_name","latitude","longitude")],Densify = T)

#Get Stations
St20=read.csv("Scripts/Subarea_481_transects_and_stations/ASAM-24-Stations-20Nm-max.csv")
St20p=create_Points(St20[,c("Latitude","Longitude","ID")])
St40=read.csv("Scripts/Subarea_481_transects_and_stations/ASAM-24-Stations-40Nm-max.csv")
St40p=create_Points(St40[,c("Latitude","Longitude","ID")])
St20_40=read.csv("Scripts/Subarea_481_transects_and_stations/ASAM-24-Stations-20and40Nm-max.csv")
St20_40p=create_Points(St20_40[,c("Latitude","Longitude","ID")])



#Extract MUs labels 
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
R_St20=Rotate_obj(St20p,Lonzero)
R_St40=Rotate_obj(St40p,Lonzero)
R_St20_40=Rotate_obj(St20_40p,Lonzero)

#Get transects midpoints to add labels
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

#Adjust MUs labels
R_labs$y[R_labs$id=="DP1"]=2800000
R_labs$y[R_labs$id=="JOIN"]=3000000
R_labs$y[R_labs$id=="BS"]=2980000


#Plots


png(filename="Figures/ASAM-2024-Transects_and_Stations_20nmi_Max.png",width=2700,height=3000,res=600)
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



png(filename="Figures/ASAM-2024-Transects_and_Stations_40nmi_Max.png",width=2700,height=3000,res=600)
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



png(filename="Figures/ASAM-2024-Transects_and_Stations_20and40nmi_Max.png",width=2700,height=3000,res=600)
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


#Export shapefiles
Tsp$Source="WG-ASAM-2024"
St20p$Source="WG-ASAM-2024"
St40p$Source="WG-ASAM-2024"
St20_40p$Source="WG-ASAM-2024"

st_write(Tsp, "Scripts/Subarea_481_transects_and_stations/WG-ASAM-24_Transects.shp",append=F,quiet=T)
st_write(St20p, "Scripts/Subarea_481_transects_and_stations/WG-ASAM-24_Stations_20nmi.shp",append=F,quiet=T)
st_write(St40p, "Scripts/Subarea_481_transects_and_stations/WG-ASAM-24_Stations_40nmi.shp",append=F,quiet=T)
st_write(St20_40p, "Scripts/Subarea_481_transects_and_stations/WG-ASAM-24_Stations_20_and_40nmi.shp",append=F,quiet=T)

#Delete GEBCO file (optional, used here to keep the repository light)
Fs=list.files()
Fs=Fs[grep("GEBCO",Fs)]
a=file.remove(Fs)