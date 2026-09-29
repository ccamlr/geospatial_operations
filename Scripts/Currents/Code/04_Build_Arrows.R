#Build arrows using the results of flow calculations
library(CCAMLRGIS)
library(dplyr)
library(colorspace)




#NB: the first two figures are for experiment 2, the last one is for experiment 3
#The figure for experiment 1 is made using "Validation_Map.R" located in the Inputs folder





#Load functions
source("Scripts/Currents/Code/Functions.R")


#Set name of input file of vertices (comment/uncomment for desired experiment)
# InFile="Polygons_For_Experiment_2.csv" #Experiment 2
InFile="Grid_For_Experiment_3.csv"     #Experiment 3

#Set a prefix to append to the output file name (comment/uncomment for desired experiment)
# Pref="Experiment_2"
Pref="Experiment_3"


#Read vertices
Input=read.csv(paste0("Scripts/Currents/Code/Inputs/",InFile))
#Read all outputs
Res=read.csv(paste0("Scripts/Currents/Code/Outputs/",Pref,"_Results.csv"))  #All results
Bal=read.csv(paste0("Scripts/Currents/Code/Outputs/",Pref,"_Balances.csv")) #Balances
Avg=read.csv(paste0("Scripts/Currents/Code/Outputs/",Pref,"_Averages.csv")) #Averages

#Get polygon centres
Pcentres=Get_Polc(InFile)
#Build projected polygons
pols=create_Polys(Input)
#Get bounding box (x/y limits)
bb=st_bbox(pols)
#get extent of area to scale arrows
FFc=max(c(bb['xmax']-bb['xmin'],bb['ymax']-bb['ymin']))

#Get mapping elements
coast=load_Coastline()


#Monthly arrows
Extr=Res
Fc=max(abs(Extr$Qe))/(FFc/1e6) #Factor to scale arrow size
#Build arrows
Arrs=Arrow_Maker()
#Export them if desired
st_write(Arrs,paste0("Scripts/Currents/Code/Outputs/",Pref,"_Arrows_monthly.gpkg"),quiet=T,append=FALSE,delete_dsn=T)

#Monthly plot
png(filename=paste0("Scripts/Currents/Code/Outputs/",Pref,"_Arrows_monthly.png"),width=3000,height=4000,res=300)
par(mai=c(0.01,0.01,0.01,0.01),lend=1,xpd=T,xaxs="i",yaxs="i")
par(mfrow=c(4,3))

for(i in seq(1,12)){
  plot(st_geometry(pols),col=rgb(0,0,1,alpha=0.2))
  plot(st_geometry(coast[coast$surface=="Land",]),add=T,col="grey")
  plot(st_geometry(coast[coast$surface=="Ice",]),add=T,col="white")
  plot(st_geometry(Arrs[Arrs$Suf==i,]),add=T,col="red",border=NA)
  text(0,0,month.name[i],cex=1.75,adj=c(0.2,0.5),font=2)
}
dev.off()



#Average arrows + time series
Extr=Avg
Fc=max(abs(Extr$Qe))/(FFc/1e6) #Factor to scale arrow size 
#Build arrows
Arrs=Arrow_Maker()
#Export them if desired
st_write(Arrs,paste0("Scripts/Currents/Code/Outputs/",Pref,"_Arrows_total.gpkg"),quiet=T,append=FALSE,delete_dsn=T)

#Color polys
Pcol=data.frame(ID=unique(Extr$ID))
Pcol$col=rainbow(nrow(Pcol))
Pcol$col=lighten(Pcol$col, amount = 0.25)
pols=left_join(pols,Pcol,by="ID")
#Compute mean per-ID flow rates to order them (so that the largest is in the back)
mf=Bal%>%group_by(ID)%>%summarise(Qm=mean(Qmax))
Bal=left_join(Bal,mf,by="ID")
Bal=arrange(Bal,desc(Qm))


LWD=65

png(filename=paste0("Scripts/Currents/Code/Outputs/",Pref,"_Arrows_total.png"),width=3000,height=4000,res=300)
par(mai=c(0.01,0.01,0.01,0.01),lend=1,xpd=T,xaxs="i",yaxs="i",cex.axis=1.5)
par(mfrow=c(2,1))

#Top: Map
plot(st_geometry(pols),col=pols$col,border=NA)
plot(st_geometry(coast[coast$surface=="Land",]),add=T,col="grey")
plot(st_geometry(coast[coast$surface=="Ice",]),add=T,col="white")
plot(st_geometry(Arrs),add=T,col="black",border=NA)
text(pols$Labx,pols$Laby,pols$ID,col="black",cex=0.75,font=2,adj=c(-1,-1))

#Bottom: time series
par(mai=c(0.5,1,0.2,1))

#Maximum Q
Exp=0.1 #expand y axes limits
XL=c(0.5,12.5)
YL=range(Bal$Qmax)
YL[1]=YL[1]-Exp*(YL[2]-YL[1])
YL[2]=YL[2]+Exp*(YL[2]-YL[1])
plot(NA,NA,ylim=YL,xlim=XL,xlab="",ylab="",axes=F)
for(id in unique(Bal$ID)){
  segments(x0=Bal$Suf[Bal$ID==id],y0=YL[1],x1=Bal$Suf[Bal$ID==id],y1=Bal$Qmax[Bal$ID==id],lwd=LWD,col=Pcol$col[Pcol$ID==id])
}
axis(1,pos=YL[1],at=seq(1,12),labels = month.abb)
axis(2,pos=XL[1],las=1)
text(XL[1],mean(YL),"Maximum Q (Sv)",srt=90,cex=1.75,xpd=T,adj=c(0.5,-3.55))
points(XL[1]-1.25,YL[2]-0.28*(YL[2]-YL[1]),pch=22,bg="grey",col="grey",cex=5)

#Sum of Q
Exp=0.6 #expand y axes limits
YL=range(Bal$QT)
YL[1]=YL[1]-Exp*(YL[2]-YL[1])
YL[2]=YL[2]+Exp*(YL[2]-YL[1])
par(new=T)
plot(NA,NA,ylim=YL,xlim=XL,xlab="",ylab="",axes=F)
for(id in unique(Bal$ID)){
  lines(Bal$Suf[Bal$ID==id],Bal$QT[Bal$ID==id],lwd=2)
  points(Bal$Suf[Bal$ID==id],Bal$QT[Bal$ID==id],pch=24,bg=Pcol$col[Pcol$ID==id],cex=3,lwd=2)
}
axis(4,pos=XL[2],las=1)
text(XL[2],mean(YL),"Sum of Q (Sv)",srt=90,cex=1.75,xpd=T,adj=c(0.5,4.3))
points(XL[2]+1.25,YL[2]-0.32*(YL[2]-YL[1]),pch=24,bg="grey",cex=3)


dev.off()




#Average map
png(filename=paste0("Scripts/Currents/Code/Outputs/",Pref,"_Arrows_total_map.png"),width=4000,height=4000,res=300)
par(mai=c(0.01,0.01,0.01,0.01),lend=1,xpd=T,xaxs="i",yaxs="i",cex.axis=1.5)
plot(st_geometry(pols),border=NA) #blank polygons, just to set the plot x/y limits
plot(st_geometry(coast[coast$surface=="Land",]),add=T,col="grey",lwd=0.1)
plot(st_geometry(coast[coast$surface=="Ice",]),add=T,col="white",lwd=0.1)
plot(st_geometry(Arrs),add=T,col="blue",border=NA)
dev.off()

