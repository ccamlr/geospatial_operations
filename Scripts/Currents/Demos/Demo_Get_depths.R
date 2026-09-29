library(CCAMLRGIS)
library(dplyr)
library(terra)

#Load Functions (to load Get_depth_values())
source("Scripts/Functions.R")

#Set depths of integration (in meters)
Dmin=0    #From
Dmax=5727 #To (max=5727)
Di=1      #Interval
Dx=seq(Dmin,Dmax,by=Di) #Vector of regularly spaced depths

#Load model outputs (download from: https://data.marine.copernicus.eu/product/GLOBAL_MULTIYEAR_PHY_001_030/files?subdataset=cmems_mod_glo_phy_my_0.083deg-climatology_P1M-m_202311 )
#Bathymetry
BM=sds("Inputs/GLO-MFC_001_030_mask_bathy.nc")
Bmod=BM["deptho"]
#Velocities (here, june for the example)
UV=sds("Inputs/mercatorglorys12v1_gl12_mean_1993_2016_06.nc") 
#Extract model values
#Eastward velocity (m/s)
Umod=UV["uo"]
#Extract depths from column names
Ds=names(Umod)
Ds=unlist(strsplit(Ds,"uo_depth="))
Ds=Ds[Ds!=""]
Ds=as.numeric(Ds)
#Northward velocity (m/s)
Vmod=UV["vo"]
#Ensure clean projection
Umod=project(Umod,"EPSG:4326")
Vmod=project(Vmod,"EPSG:4326")
Bmod=project(Bmod,"EPSG:4326")



#Set Example points:
Ps=rbind(
  c(-59.5,-62.45),
  c(-60,-60),
  c(-43.3,-65) 
)

#Check points vs bathymetry
plot(Bmod,xlim=c(-70,-40),ylim=c(-80,-50),main="bathy")
points(Ps,col="red")

#We are using arbitrary locations (Ps) for the example, but normally these are points along a polygon edge
#Extract grid cell indices at these locations
Cs=cellFromXY(Umod,Ps) 
#Use cell indices to extract model outputs
Eu=extract(Umod,Cs,raw=T)
Ev=extract(Vmod,Cs,raw=T)
EBm=extract(Bmod,Cs,raw=T)

#Run function
GetDs=Get_depth_values()
Iu=GetDs$Iu
Iv=GetDs$Iv


png(filename="Scripts/Demos/Get_Depths.png",width=3000,height=4000,res=400)
par(mai=c(0.5,0.5,0.1,0.15),lend=1,xpd=T,xaxs="i",yaxs="i")
layout(cbind(c(1,1,2,4,6),c(1,1,3,5,7)))
# layout.show(7) #Check layout

plot(Bmod,xlim=c(-78,-40),ylim=c(-77,-50),main="Model bathymetry (m)")
points(Ps,pch=21,bg="grey85",cex=5)
text(Ps[,1],Ps[,2],seq(1,3),font=2,cex=2)

#Loop over points
for(i in seq(1,3)){
  
  #Get model outputs
  Eus=as.numeric(Eu[i,])
  Evs=as.numeric(Ev[i,])
  dbot=as.numeric(EBm[i])
  #Remove values below seafloor
  iout=which(Ds>dbot)
  if(length(iout)>0){
    Eus=Eus[-iout]  
    Evs=Evs[-iout]  
    ds=Ds[-iout]
  }
  #Get interpolated values
  intU=Iu[i,]
  intV=Iv[i,]
  NoNA=which(is.na(intU)==F)
  intD=Dx[NoNA]
  intU=intU[NoNA]
  intV=intV[NoNA]

  #Plot U
  XL=range(intU,na.rm=T)
  XL[1]=XL[1]-0.1*(XL[2]-XL[1])
  XL[2]=XL[2]+0.1*(XL[2]-XL[1])
  YL=c(dbot,0)
  plot(NA,NA,ylim=YL,xlim=XL,xlab="",ylab="",axes=F)
  points(Eus,ds,pch=21,bg="blue",cex=1.4,lwd=0.1)
  points(last(intU),last(intD),pch=21,bg="red",cex=1.6,lwd=0.1)
  points(intU,intD,cex=0.1,col="green",pch=21,bg="green")
  axis(1,pos=YL[1])
  axis(2,pos=XL[1])
  if(i==3){text(mean(XL),YL[1],"Velocity (U; m/s)",cex=1.5,xpd=T,adj=c(0.5,3.5))}
  if(i==2){text(XL[1],mean(YL),"Depth (m)",srt=90,cex=1.5,xpd=T,adj=c(0.5,-3))}
  if(i==2){
    legend("topleft",cex=1.2,
           legend=c("Model depths","Bathymetry depth","Interpolated values"),
           pt.bg=c("blue","red","green"),pch=21,pt.cex = c(1.4,1.6,0.3),col=c("black","black","green"),
          pt.lwd=c(0.1,0.1,1))
  }
  points(max(XL),mean(YL),pch=21,bg="grey90",cex=5,xpd=T)
  text(max(XL),mean(YL),i,font=2,cex=2,xpd=T)
  
  #Plot V
  XL=range(intV,na.rm=T)
  XL[1]=XL[1]-0.1*(XL[2]-XL[1])
  XL[2]=XL[2]+0.1*(XL[2]-XL[1])
  YL=c(dbot,0)
  plot(NA,NA,ylim=YL,xlim=XL,xlab="",ylab="",axes=F)
  points(Evs,ds,pch=21,bg="blue",cex=1.4,lwd=0.1)
  points(last(intV),last(intD),pch=21,bg="red",cex=1.6,lwd=0.1)
  points(intV,intD,cex=0.1,col="green",pch=21,bg="green")
  axis(1,pos=YL[1])
  axis(2,pos=XL[1])
  if(i==3){text(mean(XL),YL[1],"Velocity (V; m/s)",cex=1.5,xpd=T,adj=c(0.5,3.5))}
  
  
  
}
dev.off()
