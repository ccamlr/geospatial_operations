#Script to combine files into GeoPackages
library(CCAMLRGIS)

#Load Helpers
source("I:/Science/Projects/Geospatial Operations/GIS Workflow/Polygon Builder/Scripts/Z_Helpers.R")

#List files in the Outputs folder
Files=list.files(paste0(Root,"Outputs"),full.names=T)

#Get Metadata to list classes
MD=read.csv(paste0(Root,"Inputs/Core_Geospatial_Metadata.csv"))
Cl=MD%>%group_by(Class)%>%summarise(long=unique(Class_long)[1])
Cl$long[Cl$Class!="CA"]=paste0(Cl$long[Cl$Class!="CA"],"s")
Cl$long[Cl$Class=="ASD"]="Areas, Subareas and Divisions"

for(CL in Cl$Class){
  #List Files for a class
  Files_C=Files[grep(CL,Files)]
  #Split master and cropped
  Mast=Files_C[grep("Master",Files_C)]
  Clip=Files_C[grep("Clipped",Files_C)]
  if(length(Files_C)!=sum(c(length(Mast)+length(Clip)))){stop("Geopackage building compromised.")}
  Mast_l=NULL #layer storage
  Clip_l=NULL #layer storage
  for(i in seq(1,length(Mast))){
    Mast_l=rbind(Mast_l,st_read(Mast[i],quiet=T))
    Clip_l=rbind(Clip_l,st_read(Clip[i],quiet=T))
  }
  #Export
  st_write(Mast_l,
           paste0(Root,"GeoPackages/CCAMLR_",CL,".gpkg"),layer=Cl$long[Cl$Class==CL]
           ,quiet=T,append=FALSE,delete_dsn=T)
  st_write(Clip_l,
           paste0(Root,"GeoPackages/CCAMLR_",CL,"_Clipped.gpkg"),layer=Cl$long[Cl$Class==CL]
           ,quiet=T,append=FALSE,delete_dsn=T)
}

# Use st_layers() to check files
# st_layers(paste0(Root,"GeoPackages/CCAMLR_EEZ_Clipped.gpkg"))
# st_layers(paste0(Root,"GeoPackages/CCAMLR_PD_Clipped.gpkg"))



#Combine CCAMLR and External objects into one package
#List files in the "GeoPackages" folder and the "External data" folder
CC_Files=list.files(paste0(Root,"GeoPackages"),full.names=T,pattern = 'gpkg')
Ext_Files=list.files(paste0(Root,"External data"),full.names=T,pattern = 'gpkg')
CC_Files=CC_Files[-grep("All",CC_Files)] #Remove "All" geopackage
clp=grep("Clip",CC_Files)
CC_FilesC=CC_Files[clp] #Clipped objects
CC_Files=CC_Files[-clp] #Not clipped objects

if(length(CC_Files)!=length(CC_FilesC)){stop("Mismatch between clipped and non-clipped files.")}

#Exclude HiRes and LoRes files from External datasets
Ext_Files=Ext_Files[-grep("HiRes",Ext_Files)]
Ext_Files=Ext_Files[-grep("LoRes",Ext_Files)]

# Do CCAMLR layers first
for(i in seq(1,length(CC_Files))){
  Mast_l=st_read(CC_Files[i],quiet=T)
  Clip_l=st_read(CC_FilesC[i],quiet=T)
  Lay=Cl$long[Cl$Class==Mast_l$Class[1]]
  if(i==1){
    st_write(Mast_l,
             paste0(Root,"GeoPackages/CCAMLR_All.gpkg"),layer=Lay
             ,quiet=T,append=FALSE,delete_dsn=T)
    st_write(Clip_l,
             paste0(Root,"GeoPackages/CCAMLR_All_Clipped.gpkg"),layer=Lay
             ,quiet=T,append=FALSE,delete_dsn=T)
  }else{
    st_write(Mast_l,
             paste0(Root,"GeoPackages/CCAMLR_All.gpkg"),layer=Lay
             ,quiet=T,append=TRUE)
    st_write(Clip_l,
             paste0(Root,"GeoPackages/CCAMLR_All_Clipped.gpkg"),layer=Lay
             ,quiet=T,append=TRUE)
  }
}

# st_layers(paste0(Root,"GeoPackages/CCAMLR_All_Clipped.gpkg"))
# st_layers(paste0(Root,"GeoPackages/CCAMLR_All.gpkg"))

# st_layers(paste0(Root,"External data/Coastline.gpkg"))
# st_layers(paste0(Root,"External data/GEBCO_Polygons_HiRes.gpkg"))

#Add External data
for(i in seq(1,length(Ext_Files))){
  Ext_l=st_read(Ext_Files[i],quiet=T)
  Lay=st_layers(Ext_Files[i])
  Lay=Lay$name
  
  st_write(Ext_l,
           paste0(Root,"GeoPackages/CCAMLR_All.gpkg"),layer=Lay
           ,quiet=T,append=TRUE)
  st_write(Ext_l,
           paste0(Root,"GeoPackages/CCAMLR_All_Clipped.gpkg"),layer=Lay
           ,quiet=T,append=TRUE)
  
}
# st_layers(paste0(Root,"GeoPackages/CCAMLR_All_Clipped.gpkg"))
# st_layers(paste0(Root,"GeoPackages/CCAMLR_All.gpkg"))




#Plots###################

Master=st_layers(paste0(Root,"GeoPackages/CCAMLR_All.gpkg")) #Use this to see the indices of CCAMLR Layers
Masters=NULL
for(i in seq(1,12)){
  Masters=rbind(Masters,st_read(paste0(Root,"GeoPackages/CCAMLR_All.gpkg"),layer=Master$name[i],quiet=T))
}


png(filename=paste0(Root,"GeoPackages/Plots/CCAMLR_All.png"),width=5000,height=5000,res=600)
par(mai=rep(0,4),xaxs="i",yaxs="i")
plot(st_geometry(Masters[Masters$Class=="ASD",]),col=rainbow(nrow(Masters[Masters$Class=="ASD",])))
plot(st_geometry(Masters[Masters$ID=="48",]),border=rgb(1,0,0,alpha=0.5),lwd=5,add=T)
plot(st_geometry(Masters[Masters$ID=="58",]),border=rgb(0,1,0,alpha=0.5),lwd=5,add=T)
plot(st_geometry(Masters[Masters$ID=="88",]),border=rgb(0,0,1,alpha=0.5),lwd=5,add=T)
plot(st_geometry(Masters[Masters$Class=="SSRU",]),add=T)
plot(st_geometry(Masters[Masters$Class=="RB",]),add=T,border="grey",lwd=2)
plot(st_geometry(Masters[Masters$Class=="PD",]),add=T,border="cyan",lwd=2)
plot(st_geometry(Masters[Masters$Class=="MA",]),add=T,border="darkblue",lwd=2)
plot(st_geometry(Masters[Masters$Class=="EEZ",]),add=T,border="red",lwd=2)
plot(st_geometry(Masters[Masters$Class=="MPA",]),add=T,border="brown",lwd=2)
plot(st_geometry(Masters[Masters$Class=="SSMU",]),add=T,border="darkgreen",lwd=2)
plot(st_geometry(Masters[Masters$Class=="KFMU",]),add=T,border="green",lwd=2)
plot(st_geometry(Masters[Masters$Class=="CEMP",]),add=T,col="black",lwd=1)
plot(st_geometry(Masters[Masters$Class=="VME",]),add=T,col="orange",lwd=1)
dev.off()


Clipped=NULL
for(i in seq(1,12)){
  Clipped=rbind(Clipped,st_read(paste0(Root,"GeoPackages/CCAMLR_All_Clipped.gpkg"),layer=Master$name[i],quiet=T))
}

png(filename=paste0(Root,"GeoPackages/Plots/CCAMLR_All_Clipped.png"),width=5000,height=5000,res=600)
par(mai=rep(0,4),xaxs="i",yaxs="i")
plot(st_geometry(Clipped[Clipped$Class=="ASD",]),col=rainbow(nrow(Clipped[Clipped$Class=="ASD",])))
plot(st_geometry(Clipped[Clipped$ID=="48",]),border=rgb(1,0,0,alpha=0.5),lwd=5,add=T)
plot(st_geometry(Clipped[Clipped$ID=="58",]),border=rgb(0,1,0,alpha=0.5),lwd=5,add=T)
plot(st_geometry(Clipped[Clipped$ID=="88",]),border=rgb(0,0,1,alpha=0.5),lwd=5,add=T)
plot(st_geometry(Clipped[Clipped$Class=="SSRU",]),add=T)
plot(st_geometry(Clipped[Clipped$Class=="RB",]),add=T,border="grey",lwd=2)
plot(st_geometry(Clipped[Clipped$Class=="PD",]),add=T,border="cyan",lwd=2)
plot(st_geometry(Clipped[Clipped$Class=="MA",]),add=T,border="darkblue",lwd=2)
plot(st_geometry(Clipped[Clipped$Class=="EEZ",]),add=T,border="red",lwd=2)
plot(st_geometry(Clipped[Clipped$Class=="MPA",]),add=T,border="brown",lwd=2)
plot(st_geometry(Clipped[Clipped$Class=="SSMU",]),add=T,border="darkgreen",lwd=2)
plot(st_geometry(Clipped[Clipped$Class=="KFMU",]),add=T,border="green",lwd=2)
plot(st_geometry(Clipped[Clipped$Class=="CEMP",]),add=T,col="black",lwd=1)
plot(st_geometry(Clipped[Clipped$Class=="VME",]),add=T,col="orange",lwd=1)
dev.off()



#ASDs
Old=load_ASDs()
New=Clipped[Clipped$Class=="ASD" & Clipped$ID%in%c("48","58","88")==F,]
PlotName="ASDs"

png(filename=paste0(Root,"GeoPackages/Plots/CCAMLR_",PlotName,".png"),width=8000,height=8000,res=600)
par(mai=rep(0.01,4),xaxs="i",yaxs="i",xpd=T)
plot(st_geometry(Old),border="red",lwd=3)
plot(st_geometry(New),add=T)
text(New$Labx,New$Laby,New$ID,cex=2)
legend("topleft",legend=c("Old","New"),col=c("red","black"),lwd=c(3,1),cex=2)
dev.off()

#EEZs
Old=load_EEZs()
New=Clipped[Clipped$Class=="EEZ",]
PlotName="EEZs"

png(filename=paste0(Root,"GeoPackages/Plots/CCAMLR_",PlotName,".png"),width=8000,height=8000,res=600)
par(mai=rep(0.01,4),xaxs="i",yaxs="i",xpd=T)
plot(st_geometry(Old),border="red",lwd=3)
plot(st_geometry(New),add=T)
text(New$Labx,New$Laby,New$ID,cex=2)
legend("topleft",legend=c("Old","New"),col=c("red","black"),lwd=c(3,1),cex=2)
dev.off()

#KFMUs
Old=suppressWarnings(st_read("I:/Science/Projects/Geospatial Operations/GitHub/geospatial_operations/Scripts/Krill_Fishery_Management_Units/KFMUs_V2/EMM_24_Candidate_Krill_MUs_V2.shp",quiet=T))
New=Clipped[Clipped$Class=="KFMU",]
PlotName="KFMUs"

png(filename=paste0(Root,"GeoPackages/Plots/CCAMLR_",PlotName,".png"),width=8000,height=8000,res=600)
par(mai=rep(0.01,4),xaxs="i",yaxs="i",xpd=T)
plot(st_geometry(Old),border="red",lwd=3)
plot(st_geometry(New),add=T)
text(New$Labx,New$Laby,New$ID,cex=2)
legend("topleft",legend=c("Old","New"),col=c("red","black"),lwd=c(3,1),cex=2)
dev.off()

#MAs
Old=load_MAs()
New=Clipped[Clipped$Class=="MA",]
PlotName="MAs"

png(filename=paste0(Root,"GeoPackages/Plots/CCAMLR_",PlotName,".png"),width=8000,height=8000,res=600)
par(mai=rep(0.01,4),xaxs="i",yaxs="i",xpd=T)
plot(st_geometry(Old),border="red",lwd=3)
plot(st_geometry(New),add=T)
text(New$Labx,New$Laby,New$ID,cex=1)
legend("topleft",legend=c("Old","New"),col=c("red","black"),lwd=c(3,1),cex=2)
dev.off()


#MPAs
Old=load_MPAs()
New=Clipped[Clipped$Class=="MPA",]
PlotName="MPAs"

png(filename=paste0(Root,"GeoPackages/Plots/CCAMLR_",PlotName,".png"),width=8000,height=8000,res=600)
par(mai=rep(0.01,4),xaxs="i",yaxs="i",xpd=T)
plot(st_geometry(Old),border="red",lwd=3)
plot(st_geometry(New),add=T)
text(New$Labx,New$Laby,New$ID,cex=2)
legend("topleft",legend=c("Old","New"),col=c("red","black"),lwd=c(3,1),cex=2)
dev.off()


#PDs
Old=suppressWarnings(st_read("I:/Science/Projects/MPAs/PDs/CCAMLR_MPAPD_EPSG6932.shp",quiet=T))
New=Clipped[Clipped$Class=="PD",]
PlotName="PDs"

png(filename=paste0(Root,"GeoPackages/Plots/CCAMLR_",PlotName,".png"),width=8000,height=8000,res=600)
par(mai=rep(0.01,4),xaxs="i",yaxs="i",xpd=T)
plot(st_geometry(Old),border="red",lwd=3)
plot(st_geometry(New),add=T)
text(New$Labx,New$Laby,New$ID,cex=3)
legend("topleft",legend=c("Old","New"),col=c("red","black"),lwd=c(3,1),cex=2)
dev.off()

#RBs
Old=load_RBs()
New=Clipped[Clipped$Class=="RB",]
PlotName="RBs"

png(filename=paste0(Root,"GeoPackages/Plots/CCAMLR_",PlotName,".png"),width=8000,height=8000,res=600)
par(mai=rep(0.01,4),xaxs="i",yaxs="i",xpd=T)
plot(st_geometry(Old),border="red",lwd=3)
plot(st_geometry(New),add=T)
text(New$Labx,New$Laby,New$ID,cex=1)
legend("topleft",legend=c("Old","New"),col=c("red","black"),lwd=c(3,1),cex=2)
dev.off()


#SSMUs
Old=load_SSMUs()
New=Clipped[Clipped$Class=="SSMU",]
PlotName="SSMU"

png(filename=paste0(Root,"GeoPackages/Plots/CCAMLR_",PlotName,".png"),width=8000,height=8000,res=600)
par(mai=rep(0.01,4),xaxs="i",yaxs="i",xpd=T)
plot(st_geometry(Old),border="red",lwd=3)
plot(st_geometry(New),add=T)
text(New$Labx,New$Laby,New$ID,cex=1)
legend("topleft",legend=c("Old","New"),col=c("red","black"),lwd=c(3,1),cex=2)
dev.off()


#SSRUs
Old=load_SSRUs()
New=Clipped[Clipped$Class=="SSRU",]
PlotName="SSRUs"

png(filename=paste0(Root,"GeoPackages/Plots/CCAMLR_",PlotName,".png"),width=8000,height=8000,res=600)
par(mai=rep(0.01,4),xaxs="i",yaxs="i",xpd=T)
plot(st_geometry(Old),border="red",lwd=3)
plot(st_geometry(New),add=T)
text(New$Labx,New$Laby,New$ID,cex=1)
legend("topleft",legend=c("Old","New"),col=c("red","black"),lwd=c(3,1),cex=2)
dev.off()
















#########################

#Optional: send notification of completion
PBtext="Geopackages completed."
source("C:/Users/stephane/Desktop/CCAMLR/CODES/99 - PushBullet/PushBullet.R")



