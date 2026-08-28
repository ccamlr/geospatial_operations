#Script to re-build the krill fishery management units when coastlines or boundaries are updated.


#Rebuild for WG-EMM-2024 (See figures in the report)

#Load the CCAMLRGIS library
library(CCAMLRGIS)

#Before running this script, if anything has changed (eg coastline), update the version of the final shapefiles
V_MUS=2





#STEP 1: Build polygons and clip them to the coastline

#Import vertices
V=read.csv("Scripts/Krill_Fishery_Management_Units/KFMUs_V2/EMM-24_vertices.csv")

#Create projected polygons
P=create_Polys(V)
#Load coastline
coast=load_Coastline()                   
#Clip land from the polygons
P=suppressWarnings(st_difference(P,st_union(coast[coast$surface=="Land",])))


#STEP 2: Isolate polygons, inspect plots, and remove problematic polygon parts

#Find geometry type for each management unit:
#if POLYGON, the unit is a single polygon and everything is fine
#if MULTIPOLYGON, the unit is a collection of polygons, some of which may need to be deleted

#List geometry types
Geos=as.character(st_geometry_type(P))
#Get row index of MULTIPOLYGONS
MPs=which(Geos=="MULTIPOLYGON")
#Loop over multipolygons and plot them for inspection
for(i in MPs){
  #Isolate multipolygon
  MP=P[i,]
  #separate its polygons
  Ps=suppressWarnings( st_cast(MP,"POLYGON") )
  #Compute area of polygons
  Ps$Aream2=as.numeric(round(st_area(Ps)))
  #Isolate largest polygon from others and color them differently
  LrgP=which(Ps$Aream2==max(Ps$Aream2))
  Ps$col="red"
  Ps$lwd=2
  Ps$col[LrgP]="green"
  Ps$lwd[LrgP]=0.5
  
  #Plot
  png(filename=paste0("Figures/Polygons_",P$ID[i],".png"),
      width=3000,height=3000,res=600)
  par(mai=rep(0,4),xaxs="i",yaxs="i",lend=1)
  plot(st_geometry(Ps))
  plot(st_geometry(P),add=T,col="grey",lwd=0.5)
  plot(st_geometry(Ps),add=T,border=Ps$col,col=Ps$col,lwd=Ps$lwd)
  title(paste0(P$ID[i],": ",nrow(Ps)," polygons"),line=-1,cex=2)
  legend('topleft',legend = c("Main polygon","Extra polygon(s)"),
         col=c("green","red"),
         lty=1,seg.len = 0.5,lwd=5,inset=c(0.0,0.0),cex=0.5,xpd=T)
  dev.off()
}

#Inspection of the plots reveals problematic polygons for: DP2 and GS.
#Additional polygons in other management units could be addressed by adjusting boundaries.

#List management units with problematic polygons
ProbPs=c("DP2","GS")
#Loop over management units to remove problematic polygons

for(ProbP in ProbPs){
  #Find row of problematic unit
  rowP=which(P$ID==ProbP)
  #separate its polygons
  Ps=suppressWarnings( st_cast(P[rowP,],"POLYGON") )
  #Compute area of polygons
  Ps$Aream2=as.numeric(round(st_area(Ps)))
  #Keep only largest polygon
  Ps=Ps[which(Ps$Aream2==max(Ps$Aream2)),]
  #Replace original geometry with single polygon
  st_geometry(P[rowP,])=st_geometry(Ps)
  
  #Plot result
  png(filename=paste0("Figures/Polygons_",P$ID[rowP],"_fixed.png"),
      width=3000,height=3000,res=600)
  par(mai=rep(0,4),xaxs="i",yaxs="i",lend=1)
  plot(st_geometry(P[rowP,]))
  plot(st_geometry(P),add=T,col="grey",lwd=0.5)
  plot(st_geometry(P[rowP,]),add=T,border="green",col="green",lwd=0.5)
  title(paste0(P$ID[rowP]," fixed"),line=-1,cex=2)
  dev.off()
}


#STEP 3. Update metadata of P and export

#Compute areas
P$AreaKm2=as.numeric(round(st_area(P)/1e6))
#Lower case field names
colnames(P)=tolower(colnames(P))
#Add Management Units version in metadata
P$version=V_MUS
#Add coastline version in metadata
P$cstvrsn=unique(coast$version)

#Export table of areas
Areas=st_drop_geometry(P)
Areas=Areas[,c(1,2)]
colnames(Areas)=c("Candidate Management Unit","Marine Area (sq. km)")
write.csv(Areas,"Scripts/Krill_Fishery_Management_Units/KFMUs_V2/EMM_24_Management_Units_Areas.csv",row.names = F)

#Export Shapefile 
st_write(P, paste0("Scripts/Krill_Fishery_Management_Units/KFMUs_V2/EMM_24_Candidate_Krill_MUs_V",V_MUS,".shp"),
         append = F,quiet = T)
