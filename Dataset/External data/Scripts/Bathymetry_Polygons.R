#This script uses ms_simplify to build light multi-polygon bathymetry
#Need to stick to <100Mb for GitHub

#Requirements:
#rmapshaper R library

#Then install mapshaper to use the "system" option of rmapshaper:
#1. download the nodejs installer from https://nodejs.org/en/download (NB this is also good when you want to update everything)
#2. run the installer and tick the "Automatically install the necessary tools" box during installation
#3. It's gonna take a while, with a bunch of windows, some needing interaction (just say yes to everything)
#4. Install mapshaper by typing in a command prompt: npm install -g mapshaper
#5. In R, type rmapshaper::check_sys_mapshaper() to check it is installed
#6. If after typing that you get a message that says "You need to upgrade your system mapshaper library",
#open a command prompt and type: npm update -g mapshaper.

library(CCAMLRGIS)
library(terra)
library(rmapshaper)
library(dplyr)

#Set year of Bathymetry (check the latest available in Science/Projects/GEBCO)
Year=2025

#The rest should be automatic




#Get bathymetry 
Bathy=rast(paste0("I:/Science/Projects/GEBCO/",Year,"/Processed/GEBCO",Year,"_2500.tif"))

#Give path to output folder
Pth="I:/Science/Projects/Geospatial Operations/GitHub/geospatial_operations/Dataset/External data/"


Iso=get_iso_polys(Bathy,Cuts=Depth_cuts[1:13],Cols=Depth_cols[1:12])
Iso=st_collection_extract(Iso,"POLYGON")
gc()

# unique(st_geometry_type(Iso))

#Get Colorscale
Col=st_drop_geometry(Iso)%>%group_by(Min,Max)%>%summarise(iso=unique(Iso),col=unique(c),.groups='drop')
Col=arrange(Col,Min)
Cuts=unique(c(Col$Min,Col$Max))
Cols=Col$col

Iso$Scale_cols=NA
Iso$Scale_cuts=NA
Iso$Scale_cols[1:length(Cols)]=Cols
Iso$Scale_cuts[1:length(Cuts)]=Cuts



#Simplify

#Hi-res
Iso_ms=ms_simplify(Iso,keep=1,sys=T)

Iso_ms=Iso_ms%>%select(Iso,Min,Max,col=c,Scale_cols,Scale_cuts)
#Some polygons might have been dropped and taken the colorscale info with them. Put it back in:
Iso_ms$Scale_cols=Iso$Scale_cols[1:nrow(Iso_ms)]
Iso_ms$Scale_cuts=Iso$Scale_cuts[1:nrow(Iso_ms)]
st_write(Iso_ms, paste0(Pth,"GEBCO_Polygons_HiRes.gpkg"),
         layer=paste0("GEBCO ",Year," Polygons HiRes"),quiet=T,append=FALSE,delete_dsn=T)
rm(Iso_ms)
Iso_ms=st_read(paste0(Pth,"GEBCO_Polygons_HiRes.gpkg"),quiet=T)


png(filename=paste0(Pth,"Scripts/Bathy_01_HiRes.png"),width=10000,height=5000,res=600)
par(mai=rep(0.1,4),xaxs="i",yaxs="i",mfcol=c(1,2),bg="red")
plot(st_geometry(Iso_ms),col=Iso_ms$col,border=NA,main="High")
plot(st_geometry(Iso_ms),col=Iso_ms$col,xlim=c(-3e6,-2e6),ylim=c(1e6,2e6),border=NA)
add_Cscale(cuts=Iso_ms$Scale_cuts[is.na(Iso_ms$Scale_cuts)==F],
           cols=Iso_ms$Scale_cols[is.na(Iso_ms$Scale_cols)==F],
           offset=-1000,fontsize=1.4)
dev.off()



#Mid-red
Iso_ms=ms_simplify(Iso,keep=0.5,sys=T)

Iso_ms=Iso_ms%>%select(Iso,Min,Max,col=c,Scale_cols,Scale_cuts)
#Some polygons might have been dropped and taken the colorscale info with them. Put it back in:
Iso_ms$Scale_cols=Iso$Scale_cols[1:nrow(Iso_ms)]
Iso_ms$Scale_cuts=Iso$Scale_cuts[1:nrow(Iso_ms)]
st_write(Iso_ms, paste0(Pth,"GEBCO_Polygons_MidRes.gpkg"),
         layer=paste0("GEBCO ",Year," Polygons MidRes"),quiet=T,append=FALSE,delete_dsn=T)
rm(Iso_ms)
Iso_ms=st_read(paste0(Pth,"GEBCO_Polygons_MidRes.gpkg"),quiet=T)

png(filename=paste0(Pth,"Scripts/Bathy_02_MidRes.png"),width=10000,height=5000,res=600)
par(mai=rep(0.1,4),xaxs="i",yaxs="i",mfcol=c(1,2),bg="red")
plot(st_geometry(Iso_ms),col=Iso_ms$c,border=NA,main="Mid")
plot(st_geometry(Iso_ms),col=Iso_ms$c,xlim=c(-3e6,-2e6),ylim=c(1e6,2e6),border=NA)
add_Cscale(cuts=Iso_ms$Scale_cuts[is.na(Iso_ms$Scale_cuts)==F],
           cols=Iso_ms$Scale_cols[is.na(Iso_ms$Scale_cols)==F],
           offset=-1000,fontsize=1.4)
dev.off()



#Lo-res
Iso_ms=ms_simplify(Iso,keep=0.1,sys=T)

Iso_ms=Iso_ms%>%select(Iso,Min,Max,col=c,Scale_cols,Scale_cuts)
#Some polygons might have been dropped and taken the colorscale info with them. Put it back in:
Iso_ms$Scale_cols=Iso$Scale_cols[1:nrow(Iso_ms)]
Iso_ms$Scale_cuts=Iso$Scale_cuts[1:nrow(Iso_ms)]
st_write(Iso_ms, paste0(Pth,"GEBCO_Polygons_LoRes.gpkg"),
         layer=paste0("GEBCO ",Year," Polygons LoRes"),quiet=T,append=FALSE,delete_dsn=T)
rm(Iso_ms)
Iso_ms=st_read(paste0(Pth,"GEBCO_Polygons_LoRes.gpkg"),quiet=T)


png(filename=paste0(Pth,"Scripts/Bathy_03_LoRes.png"),width=10000,height=5000,res=600)
par(mai=rep(0.1,4),xaxs="i",yaxs="i",mfcol=c(1,2),bg="red")
plot(st_geometry(Iso_ms),col=Iso_ms$c,border=NA,main="Low")
plot(st_geometry(Iso_ms),col=Iso_ms$c,xlim=c(-3e6,-2e6),ylim=c(1e6,2e6),border=NA)
add_Cscale(cuts=Iso_ms$Scale_cuts[is.na(Iso_ms$Scale_cuts)==F],
           cols=Iso_ms$Scale_cols[is.na(Iso_ms$Scale_cols)==F],
           offset=-1000,fontsize=1.4)
dev.off()



#Optional: send notification of completion
PBtext="Bathymetry Polygons completed."
source("C:/Users/stephane/Desktop/CCAMLR/CODES/99 - PushBullet/PushBullet.R")


