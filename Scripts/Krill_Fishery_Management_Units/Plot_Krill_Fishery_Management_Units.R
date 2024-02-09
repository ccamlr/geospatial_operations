#Script to plot the krill fishery management units as built by Krill_Fishery_Management_Units_Vx_x.R

#Load the CCAMLRGIS library
library(CCAMLRGIS)

#Set shapefile version
V_MUS=1


#Load the units
P=st_read(paste0("Scripts/Krill_Fishery_Management_Units/Candidate_Krill_MUs_V",V_MUS,".shp"),quiet = T)

#Load the coastline
coast=load_Coastline()

#Extract labels 
Labs=st_drop_geometry(P[,c("id","labx","laby")])
Labs=project_data(Labs,NamesIn=c("laby","labx"),inv=T)
Labs=create_Points(Labs[,c("Latitude","Longitude","id")])

#Rotate objects
Lonzero=-60 #This longitude will point up
R_P=Rotate_obj(P,Lonzero)
R_coast=Rotate_obj(coast,Lonzero)
R_labs=Rotate_obj(Labs,Lonzero)
R_labs$x=st_coordinates(R_labs)[,1]
R_labs$y=st_coordinates(R_labs)[,2]


#Create a bounding box for the region
bb=st_bbox(st_buffer(R_P,20000)) #Get bounding box (x/y limits) + buffer
bx=st_as_sfc(bb) #Build spatial box to plot

#Use spatial box to crop coastline
R_coast=suppressWarnings(st_intersection(R_coast,bx))


#Plot
png(filename=paste0("Scripts/Krill_Fishery_Management_Units/Candidate_Krill_MUs_V",V_MUS,"_Map.png"),
width=2700,height=3000,res=600)
par(mai=rep(0,4))
plot(bx,lwd=0.1,xpd=T)
plot(st_geometry(R_coast[R_coast$surface=="Ice",]),col="white",lwd=0.5,add=T)
plot(st_geometry(R_P),border="black",lwd=1.5,add=T)
plot(st_geometry(R_coast[R_coast$surface=="Land",]),col="grey",add=T)
add_RefGrid(bb=bb,ResLat = 2.5,ResLon = 5,lwd=0.5,fontsize = 0.75)
plot(bx,lwd=1,add=T,xpd=T)

text(R_labs$x,R_labs$y,R_labs$id)

dev.off()

