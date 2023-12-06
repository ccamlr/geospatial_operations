#Script Version 1.0


#This scripts builds a coastline polygons dataset by combining BAS (ADD) data (60S-90S)
#and Natural Earth data (40S-60S).
#Sources:
#BAS: https://data.bas.ac.uk/datasets.php?page=1&topic=Land+Surface&term=Topography
#https://data.bas.ac.uk/full-record.php?id=GB/NERC/BAS/PDC/01787 (High resolution vector polygons of the Antarctic coastline - VERSION 7.8)
#https://data.bas.ac.uk/full-record.php?id=GB/NERC/BAS/PDC/01430 (Vector polygons of the Sub-Antarctic coastline - VERSION 7.3)
#The second link is to get coastlines between 50W and 20W
#NE: https://www.naturalearthdata.com/downloads/10m-physical-vectors/ (Land polygons including major islands; and; Islands that are 2 sq. km or less in size.)

library(CCAMLRGIS)
library(dplyr)

#1. Import raw data
NE=st_read("Scripts/Coastline/NE/ne_10m_land.shp",quiet = T)
NEi=st_read("Scripts/Coastline/NE/ne_10m_minor_islands.shp",quiet = T)
BAS=st_read("Scripts/Coastline/BAS/add_coastline_high_res_polygon_v7_8.shp",quiet = T)
BASsub=st_read("Scripts/Coastline/BAS/sub_antarctic_coastline_high_res_polygon_v1.0.shp",quiet = T)

#Inform versions of datasets
NEv="5.1.1"
NEiv="4.1.0"
BASv="7.8"
BASsubv="7.3"
CCAMLRv="1.0"

#2. Crop NE to 60S-40S
sf_use_s2(FALSE)
NE = st_crop(NE, xmin=-180,ymin=-60,xmax=180,ymax=-40 )
# plot(st_geometry(NE),col="grey")
NEi = st_crop(NEi, xmin=-180,ymin=-60,xmax=180,ymax=-40 )
# plot(st_geometry(NEi),col="grey")
sf_use_s2(TRUE)

#3. Build a box to replace NE data with BASsub data between 50W and 20W
lons=c(-50,-20,-20,-50,-50)
lats=c(-50,-50,-60,-60,-50)
Box=st_sfc(st_polygon(list(cbind(lons,lats))), crs = 4326)
plot(Box)
plot(st_geometry(NE),col="grey",add=T)
NE=st_difference(NE,Box) #Remove box area from NE
NEi=st_difference(NEi,Box) #Remove box area from NEi
BASsub=st_transform(BASsub,4326)
BASsub=st_intersection(BASsub,Box) #Keep box area from BASsub

#4. Project objects to 6932
BAS=st_transform(BAS,6932)
BASsub=st_transform(BASsub,6932)
NE=st_transform(NE,6932)
NEi=st_transform(NEi,6932)

#5. Isolate layers and plot
unique(BAS$surface)

png(filename="Scripts/Coastline/Raw_Layers.png",width=3000,height=3000,res=600)
par(mai=rep(0,4))
plot(st_geometry(NE),col="orange",lwd=0.01)
plot(st_geometry(NEi),col="cyan",add=T,lwd=0.01)
plot(st_geometry(BASsub),col="darkgreen",add=T,lwd=0.01)
plot(st_geometry(BAS[BAS$surface=="land",]),col="blue",add=T,lwd=0.01)
plot(st_geometry(BAS[BAS$surface=="ice shelf",]),col="grey",add=T,lwd=0.01)
plot(st_geometry(BAS[BAS$surface=="ice tongue",]),col="green",add=T,lwd=0.01)
plot(st_geometry(BAS[BAS$surface=="rumple",]),col="red",add=T,lwd=0.01)
legend("bottomleft",legend=c('BAS land','BAS ice shelf','BAS ice tongue','BAS rumple',
                             'BASsub','NE','NE minor islands'),
       fill=c('blue','grey','green','red','darkgreen','orange','cyan'),
       seg.len=0,cex=0.75,
       xpd=TRUE)
dev.off()

#6. Separate BAS land from ice
BASland=BAS%>%filter(surface=="land")
BASice_shelves=BAS%>%filter(surface=="ice shelf")
BASice_tongues=BAS%>%filter(surface=="ice tongue")
BASice_rumples=BAS%>%filter(surface=="rumple")

#7. Densify South America (SA) and New Zealand's (NZ) north island
#This is to ensure they are curved where they are cropped, after projection
NE=st_cast(NE,"POLYGON")
NE$area=st_area(NE)
NE=arrange(NE,desc(area)) #Sort polygons by decreasing area
SA=NE[1,] #SA is the first (ie largest) polygon
plot(st_geometry(NE),col="grey")
plot(st_geometry(SA),col="green",add=T)
NZ=NE[5,] #NZ north island is the fifth polygon
plot(st_geometry(NE),col="grey")
plot(st_geometry(NZ),col="green",add=T)

#Back-project polygon, isolate coordinates, densify, then replace in dataset
#SA
SA=st_transform(SA,4326)
coord=as.data.frame(st_coordinates(SA))
coord$X=round(coord$X,7)
coord$Y=round(coord$Y,7)
coord=CCAMLRGIS:::DensifyData(Lon=coord$X,Lat=coord$Y)
pol=st_sfc(st_polygon(list(coord)), crs = 4326)
SA$geometry=pol #Replace geometry with densified one
SA=st_transform(SA,6932)
plot(st_geometry(SA),col="grey")
#NZ
NZ=st_transform(NZ,4326)
coord=as.data.frame(st_coordinates(NZ))
coord$X=round(coord$X,7)
coord$Y=round(coord$Y,7)
coord=CCAMLRGIS:::DensifyData(Lon=coord$X,Lat=coord$Y)
pol=st_sfc(st_polygon(list(coord)), crs = 4326)
NZ$geometry=pol #Replace geometry with densified one
NZ=st_transform(NZ,6932)
plot(st_geometry(NZ),col="grey")

#Put polygons back in NE
NE=NE[-1,]
NE=rbind(SA,NE)
NE=NE[-5,]
NE=rbind(NZ,NE)

plot(st_geometry(NE),col="grey")

#Unionize and merge polygons
NE=NE%>%select(-area)
NE=rbind(NE,NEi)
NE=st_union(NE)

BASsub$surface="land"
BASsub=BASsub%>%select(surface)
BASland=rbind(BASland,BASsub)
BASland=st_union(BASland)
BASice_shelves=st_union(BASice_shelves)
BASice_tongues=st_union(BASice_tongues)
BASice_rumples=st_union(BASice_rumples)

#Merge all into one Land and one Ice
Land=c(NE,BASland)
Ice=c(BASice_shelves,BASice_tongues,BASice_rumples)

#Set data frames, including versions
DFLand=data.frame(Version=CCAMLRv,
                  Source=c("Natural Earth","BAS"),
                  SrcVrsn=c(
                    paste0("Land V",NEv," and Minor Islands V",NEiv),
                    paste0("Ant. coastline V",BASv," and Sub-Ant. coastline V",BASsubv)
                  ),
                  Layer="Land",Surface="Land")
Land=st_set_geometry(DFLand,Land)

DFIce=data.frame(Version=CCAMLRv,
                 Source="BAS",
                 SrcVrsn=paste0("Ant. coastline V",BASv),
                 Layer=c("Ice shelves","Ice tongues","Ice rumples")
                 ,Surface="Ice")
Ice=st_set_geometry(DFIce,Ice)

#Merge everything into one file
Coast=rbind(Land,Ice)

#Check dataframe
st_drop_geometry(Coast)

#Coast is now ready, in maximum resolution.
png(filename="Scripts/Coastline/Merged_Layers_MaxRes.png",width=3000,height=3000,res=600)
par(mai=rep(0,4))
plot(st_geometry(Coast[Coast$Source=="Natural Earth",]),col="orange",lwd=0.01)
plot(st_geometry(Coast[Coast$Source=="BAS" & Coast$Layer=="Land",]),col="blue",add=T,lwd=0.01)
plot(st_geometry(Coast[Coast$Layer=="Ice shelves",]),col="grey",add=T,lwd=0.01)
plot(st_geometry(Coast[Coast$Layer=="Ice tongues",]),col="green",add=T,lwd=0.01)
plot(st_geometry(Coast[Coast$Layer=="Ice rumples",]),col="red",add=T,lwd=0.01)
legend("bottomleft",legend=c('BAS land','BAS ice shelves','BAS ice tongues','BAS ice rumples','Natural Earth land'),
       fill=c('blue','grey','green','red','orange'),
       seg.len=0,cex=0.75,
       xpd=TRUE)
dev.off()

#Export if desired
# st_write(Coast, "Coast_MaxResolution.shp",append = F,quiet = T)

#Simplify with 10m tolerance
coast=st_simplify(Coast,preserveTopology=T,dTolerance=10)

#Export
DashedVersion=gsub(".","_",CCAMLRv,fixed = T)
st_write(coast, paste0("Scripts/Coastline/CCAMLR_Coastline_V",DashedVersion,".shp"),append = F,quiet = T)
