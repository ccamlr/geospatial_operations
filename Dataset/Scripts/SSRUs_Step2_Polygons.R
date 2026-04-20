#Script to build/update Polygons

#Set the name of this script
sName="SSRUs_Step2_Polygons.R"

#The rest should be automatic

#Load Helpers
source("Dataset/Scripts/Z_Helpers.R")

#Load coastline (if it wasn't loaded in '0_Run_Scripts')
if(exists("COAST")==F){
  coast=load_Coastline()
  coast=coast[coast$surface=="Land",]
  coast=st_union(coast)
}else{
  coast=COAST
}

coast_all=coast


#List SSRUs
ssrus=c('486A','486B','486C','486D','486E','486F','486G',
        '5841A','5841B','5841C','5841D','5841E','5841F','5841G','5841H',
        '5842A','5842B','5842C','5842D','5842E',
        '5843aA','5843bA','5843bB','5843bC','5843bD','5843bE',
        '5844aA','5844aB','5844aD','5844bB','5844bC','5844bD',
        '586B','586C','586D',
        '587A','587B',
        '881A','881B','881C','881D','881E','881F','881G','881H','881I','881J','881K','881L','881M',
        '882A','882B','882C','882D','882E','882F','882G','882H','882I',
        '883A','883B','883C','883D')


# pName='883D'

for(pName in ssrus){
  
  #Load Master Vertices
  Vs=Load_Vs(Type="M")
  MV=Vs$MV #Master Vertices
  
  
  
  #Build Master polygon and plot
  P_Master=create_Polys(Input = data.frame(Name=pName,
                                           Lat=MV$Latitude,
                                           Lon=MV$Longitude))
  BB=st_bbox(st_buffer(P_Master,20000)) #Get bounding box (x/y limits) + buffer
  coast=suppressWarnings(st_intersection(coast_all,st_as_sfc(BB))) #Crop coast
  
  Plot_master(Fname=paste0("SSRU_",pName))
  
  #clip to the coastline (if any) and plot
  P_Clipped=NULL
  tryCatch({
    P_Clipped=suppressWarnings(st_difference(P_Master,coast))
  },error=function(e){message(paste0("No coastline to clip for ",pName))})
  if(is.null(P_Clipped)){P_Clipped=P_Master}
  
  Plot_clipped(Fname=paste0("SSRU_",pName))
  
  #Add Metadata
  MD=Add_Metadata()
  P_Master=st_set_geometry(MD,st_geometry(P_Master))
  P_Clipped=st_set_geometry(MD,st_geometry(P_Clipped))
  
  #Export
  Export_Pol(Fname=paste0("SSRU_",pName))
  
  message(paste0(pName," in ",sName," done."))
}



gc()