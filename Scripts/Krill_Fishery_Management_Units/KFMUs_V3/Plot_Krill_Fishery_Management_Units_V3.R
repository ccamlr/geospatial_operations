#Script to plot the krill fishery management units
library(CCAMLRGIS)

#Set the URL of the files (this is temporary, eventually these files will be accessible via the CCAMLRGIS package)

URl="https://github.com/ccamlr/geospatial_operations/raw/10c7ee8d3960e22a7dd79c0663c38979c074fb38/Dataset/"
coast=st_read(paste0(URl,"External%20data/Coastline.gpkg"),quiet=T)
KFMUs=st_read(paste0(URl,"GeoPackages/CCAMLR_KFMU.gpkg"),quiet=T)

#Rotate objects
Lonzero=-60 #This longitude will point up
R_KFMUs=Rotate_obj(KFMUs,Lonzero)
R_coast=Rotate_obj(coast,Lonzero)


#Create a bounding box for the region
bb=st_bbox(st_buffer(R_KFMUs,20000)) #Get bounding box (x/y limits) + buffer
bx=st_as_sfc(bb) #Build spatial box to plot

#Use spatial box to crop coastline
R_coast=suppressWarnings(st_intersection(R_coast,bx))

#Get labels
R_labs=suppressWarnings( st_centroid(R_KFMUs) )
R_labs$x=st_coordinates(R_labs)[,1]
R_labs$y=st_coordinates(R_labs)[,2]
# adjust labels
R_labs$y[R_labs$ID=="DP2"]=3100000
R_labs$y[R_labs$ID=="DP1"]=2730000
R_labs$x[R_labs$ID=="DP1"]=-340000
R_labs$y[R_labs$ID=="EI"]=3230000
R_labs$x[R_labs$ID=="GS"]=-210000
R_labs$y[R_labs$ID=="PB2"]=2850000

#Plot
png(filename="Scripts/Krill_Fishery_Management_Units/KFMUs_V3/Fig01.png",width=2700,height=3000,res=600)
par(mai=rep(0,4))
plot(bx,lwd=0.1,xpd=T)
plot(st_geometry(R_coast[R_coast$Surface=="Ice",]),col="white",lwd=0.2,add=T)
plot(st_geometry(R_KFMUs),border="black",lwd=2,add=T)
plot(st_geometry(R_coast[R_coast$Surface=="Land",]),col="grey",lwd=0.3,add=T)
add_RefGrid(bb=bb,ResLat = 2.5,ResLon = 5,lwd=0.5,fontsize = 0.75)
plot(bx,lwd=1,add=T,xpd=T)
text(R_labs$x,R_labs$y,R_labs$ID)
dev.off()

