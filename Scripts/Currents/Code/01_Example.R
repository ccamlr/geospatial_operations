#Example of flow calculation for a single polygon and a single model time step
library(terra)
library(CCAMLRGIS)
library(dplyr)

#Load functions
source("Scripts/Currents/Code/Functions.R")

#Load vertices to build a polygon
Input=data.frame(ID="Example",
                 Lat=c(-40,-40,-50,-50),
                 Lon=c(10,30,30,10))

#Set depths of integration (in meters)
Dmin=0    #From
Dmax=5727 #To (max=5727)
Di=1      #Interval
Dx=seq(Dmin,Dmax,by=Di) #Vector of regularly spaced depths

#Load model bathymetry
BM=sds("Scripts/Currents/Code/Inputs/GLO-MFC_001_030_mask_bathy.nc")
Bmod=BM["deptho"]

#Load model outputs (here, june for the example)
UV=sds("Scripts/Currents/Code/Inputs/mercatorglorys12v1_gl12_mean_1993_2016_06.nc") 

# #Check contents
# varnames(Ra)
# Ra@pntr$long_names
# Ra@pntr$units

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

# #Plot surface velocities
# par(mfcol=c(1,2))
# plot(U[[1]],main="U")
# plot(V[[1]],main="V")

Extr=Calculate_flow()

cat("Here is the flow (Qe) for each edge: \n")
print(Extr)
#Check the balance
chck=Extr%>%group_by(ID)%>%summarise(Qmax=max(abs(Qe)),QT=sum(Qe))
chck$P=100*abs(chck$QT/chck$Qmax)
chck=as.data.frame(chck)
cat("Here is the balance of flows (QT) for this polygon, as a % of the largest flow (P): \n")
print(chck)





