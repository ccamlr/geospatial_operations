#Flow calculation across several time steps
library(terra)
library(CCAMLRGIS)
library(dplyr)

#Load functions
source("Scripts/Functions.R")

#Set name of input file of vertices (comment/uncomment for desired experiment)
# InFile="Lines_For_Experiment_1.csv"    #Experiment 1
# InFile="Polygons_For_Experiment_2.csv" #Experiment 2
InFile="Grid_For_Experiment_3.csv"     #Experiment 3 !Note: this will take a while!

#Set a prefix to append to the output file name (comment/uncomment for desired experiment)
# Pref="Experiment_1"
# Pref="Experiment_2"
Pref="Experiment_3"


#The rest should be automatic

#Load vertices to build polygons
Input=read.csv(paste0("Inputs/",InFile))
#Set depths of integration (in meters)
Dmin=0    #From
Dmax=5727 #To (max=5727)
Di=1      #Interval
Dx=seq(Dmin,Dmax,by=Di) #Vector of regularly spaced depths
#Load model bathymetry
BM=sds("Inputs/GLO-MFC_001_030_mask_bathy.nc")
Bmod=BM["deptho"]
Bmod=project(Bmod,"EPSG:4326") #clean-up projection
#Build a dataframe that lists model files and adds a suffix to help arrange outputs
Runs=data.frame(
  File=paste0("mercatorglorys12v1_gl12_mean_1993_2016_",sprintf("%.2d",seq(1,12)),".nc"),
  Suf=seq(1,12)
)
Result=NULL #Prepare storage
for(run in seq(1,nrow(Runs))){
  cat(run,"\n")
  #Load model outputs
  UV=sds(paste0("Inputs/",Runs$File[run])) 
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
  #Run calculations
  Extr=Calculate_flow()
  #Append suffix
  Extr$Suf=Runs$Suf[run]
  #Store 
  Result=rbind(Result,Extr)
}
#Export Results
write.csv(Result,paste0("Outputs/",Pref,"_Results.csv"),row.names=F)

source("Scripts/03_Post_Process.R")
