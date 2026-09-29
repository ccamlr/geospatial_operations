#Demo of along-edge data extraction from Raster
library(terra)
library(CCAMLRGIS)
source("Scripts/Currents/Code/Functions.R")

#Load raster https://github.com/ccamlr/geospatial_operations/blob/main/Scripts/Currents/Code/Inputs/InputsForCurrents.md
Ra=sds("Scripts/Currents/Code/Inputs/mercatorglorys12v1_gl12_mean_1993_2016_06.nc") #June example
U=Ra["uo"]
U=project(U,"EPSG:4326")




#Step 1: define segment (ie a polygon edge) and get the ID of cells it intersects
df=data.frame( 
  Lon=c(10,10.5),
  Lat=c(-60.5,-60)
)
#Set plot limits
XL=c(9.9,10.6)
YL=c(-60.7,-59.9)



#Build geo-referenced segment
L=st_sfc(st_linestring(cbind(df$Lon,df$Lat)),crs=4326)
#Get ID of grid cells intersecting that segment, along that segment (i.e., in the right order)
Cs=extractAlong(U,vect(L),cells=T)
Cs=Cs$cell
#Get Lat/Lon of cells
xy=xyFromCell(U,Cs)

#Plot
png(filename="Scripts/Currents/Demos/Get_Edge_Values_Step1.png",width=2000,height=2200,res=300)
par(mai=c(0.6,0.6,0.2,0.2),lend=1,xpd=T,mgp=c(3,0.7,0),xaxs="i",yaxs="i")
#Set plot limits

plot(df$Lon,df$Lat,type="l",xlab="",ylab="",
     xlim=XL,ylim=YL,main="Step 1",lty=3,lwd=1,col="grey",axes=F,asp=1,cex.main=1.5)
axis(1,pos=YL[1],at=seq(XL[1],XL[2],by=0.1))
text(mean(XL),YL[1],"Longitude",adj=c(0.5,3.5),cex=1.25)
axis(2,pos=XL[1],at=seq(YL[1],YL[2],by=0.1))
text(XL[1],mean(YL),"Latitude",srt=90,adj=c(0.5,-3),cex=1.25)
points(df$Lon,df$Lat,pch=21,bg="black")
text(df$Lon,df$Lat,c(1,2),font=2,adj=c(0.5,-0.5))
points(xy[,1],xy[,2],pch=21,bg="blue")
text(xy[,1],xy[,2],seq(1,nrow(xy)),col="blue",adj=c(0.5,-0.5))
legend("topleft",
       legend=c("Edge extremities","Grid cell centres"),
       pt.bg=c("black","blue"),pch=21,inset=c(0.02,0.01),cex=1.3)
dev.off()





#Step 2: densify edge and build polygons around cell centres

#densify edge at twice the number of cells (ie ~twice the resolution)
Dist=units::set_units(seq(0,1,by=1/(2*length(Cs))), degrees)
L=suppressMessages(st_line_interpolate(L,dist=Dist,normalized=T))
L=st_cast(st_combine(L),"LINESTRING") #Now the edge is a series of small segments
Lxy=st_coordinates(L) #Extract coordinates for the plot
#build a polygon cell around each point
#get resolution of grid
rg=res(U)
Gr=Simple_grid(dlat=rg[2],dlon=rg[1],df=data.frame(Lat=xy[,2],Lon=xy[,1]))
cells=list() #store polygons in a list
for(id in Gr$ID){
  clons=Gr$Lon[Gr$ID==id]
  clats=Gr$Lat[Gr$ID==id]
  clons=c(clons,clons[1])
  clats=c(clats,clats[1])
  cel=st_polygon(list(cbind(clons,clats)))
  cells[[id]]=cel
}
#Set crs
cells=st_sfc(cells,crs=4326)
#turn into sf object
cells=st_set_geometry(data.frame(cl=names(cells)),cells)
#Check for error
if(nrow(cells)!=nrow(xy)){stop("Mismatch between the count of cells and the count of their centres")}


#Plot
png(filename="Scripts/Currents/Demos/Get_Edge_Values_Step2.png",width=2000,height=2200,res=300)
par(mai=c(0.6,0.6,0.2,0.2),lend=1,xpd=T,mgp=c(3,0.7,0),xaxs="i",yaxs="i")
plot(L,xlab="",ylab="",xlim=XL,ylim=YL,main="Step 2",lwd=1,axes=F,asp=1,cex.main=1.5)
points(Lxy[,1],Lxy[,2],pch=21,bg="green",col="green",cex=0.5)
axis(1,pos=YL[1],at=seq(XL[1],XL[2],by=0.1))
text(mean(XL),YL[1],"Longitude",adj=c(0.5,3.5),cex=1.25)
axis(2,pos=XL[1],at=seq(YL[1],YL[2],by=0.1))
text(XL[1],mean(YL),"Latitude",srt=90,adj=c(0.5,-3),cex=1.25)
plot(st_geometry(cells),add=T)
points(xy[,1],xy[,2],pch=21,bg="blue")
text(xy[,1],xy[,2],seq(1,nrow(xy)),col="blue",adj=c(0.5,-0.5))
legend("topleft",
       legend=c(paste0("Edge segments extremities (n=",nrow(Lxy)-1,")"),
                "Grid cell centres",
                paste0("Grid cells (n=",nrow(xy),")")),
       pt.bg=c("green","blue","white"),pch=c(21,21,22),inset=c(0.02,0.01),cex=1.3)
dev.off()





#Step 3: compute the intersection between the densified edge and the polygonised cells, and get the lengths of the resulting segments

#Compute intersection between cells and segment
Int=suppressWarnings(st_intersection(cells,L))
#Get length of each segment
Cl=as.numeric(st_length(Int))
#Colorize length for the plot
Cols=add_col(Cl,cuts = 6)



#Plot
png(filename="Scripts/Currents/Demos/Get_Edge_Values_Step3.png",width=2000,height=2200,res=300)
par(mai=c(0.6,0.6,0.2,0.2),lend=1,xpd=T,mgp=c(3,0.7,0),xaxs="i",yaxs="i")
plot(st_geometry(Int),xlab="",ylab="",xlim=XL,ylim=YL,main="Step 3",lwd=3,col=Cols$varcol,axes=F,asp=1,cex.main=1.5)
axis(1,pos=YL[1],at=seq(XL[1],XL[2],by=0.1))
text(mean(XL),YL[1],"Longitude",adj=c(0.5,3.5),cex=1.25)
axis(2,pos=XL[1],at=seq(YL[1],YL[2],by=0.1))
text(XL[1],mean(YL),"Latitude",srt=90,adj=c(0.5,-3),cex=1.25)
plot(st_geometry(cells),add=T)
points(xy[,1],xy[,2],pch=21,bg=Cols$varcol)
text(xy[,1],xy[,2],seq(1,nrow(xy)),col=Cols$varcol,adj=c(0.5,-0.5))
legend("topleft",
       legend=c(paste0("Edge intersections with cells (n=",nrow(Int),")"),
                "Grid cell centres",
                paste0("Grid cells (n=",nrow(xy),")")),
       pt.bg=c(NA,"grey","white"),col=c("grey","black","black"),
       pch=c(NA,21,22),lwd=c(3,NA,NA),inset=c(0.02,0.01),cex=1.3)
add_Cscale(pos='2/2',height=45,title='Length (Cl, m)',offset=-0.00012,width=20,
           cuts=round(Cols$cuts,1),cols=Cols$cols,fontsize=0.8)
dev.off()

