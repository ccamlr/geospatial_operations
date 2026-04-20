#Script to build/update Polygons

#Set the name of this script
sName="RBs_Step2_Polygons.R"

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

#List RBs
rbs=c('481_1','481_2','481_3',
      '482_N','482_S',
      '486_2','486_3','486_4','486_5',
      '5841_1','5841_2','5841_3','5841_4','5841_5','5841_6',
      '5842_1','5842_2',
      '5843a_1',
      '5844b_1','5844b_2',
      '882_1','882_2','882_3','882_4',
      '883_1','883_2','883_3','883_4','883_5','883_6','883_7','883_8','883_9','883_10','883_11','883_12')



# pName='883D'

for(pName in rbs){
  
  #Load Master Vertices
  Vs=Load_Vs(Type="M")
  MV=Vs$MV #Master Vertices
  
  #Build Master polygon and plot
  if(pName=="486_5"){ #Special case with self-intersection. Needs to be two polygons.
    #Part 1
    indx=c(seq(1,5),seq(14,17))
    P_Master1=create_Polys(Input = data.frame(Name=pName,
                                             Lat=MV$Latitude[indx],
                                             Lon=MV$Longitude[indx]))
    #Part 2
    indx=seq(6,13)
    P_Master2=create_Polys(Input = data.frame(Name=pName,
                                              Lat=MV$Latitude[indx],
                                              Lon=MV$Longitude[indx]))
    #Merge
    P_Master=rbind(P_Master1,P_Master2)
    P_Master=st_union(P_Master)
    P_Master=st_set_geometry(st_drop_geometry(P_Master1),P_Master)
    #Update Area and labs
    P_Master$AreaKm2=as.numeric(round(st_area(P_Master)/1000000,1))
    labs=st_coordinates(st_centroid(st_geometry(P_Master)))
    P_Master$Labx=labs[,1]
    P_Master$Laby=labs[,2]
  }else{
    P_Master=create_Polys(Input = data.frame(Name=pName,
                                           Lat=MV$Latitude,
                                           Lon=MV$Longitude))
  }
  
  BB=st_bbox(st_buffer(P_Master,20000)) #Get bounding box (x/y limits) + buffer
  coast=suppressWarnings(st_intersection(coast_all,st_as_sfc(BB))) #Crop coast
  
  Plot_master(Fname=paste0("RB_",pName))
  
  #clip to the coastline (if any) and plot
  P_Clipped=NULL
  tryCatch({
    P_Clipped=suppressWarnings(st_difference(P_Master,coast))
  },error=function(e){message(paste0("No coastline to clip for ",pName))})
  if(is.null(P_Clipped)){P_Clipped=P_Master}
  
  Plot_clipped(Fname=paste0("RB_",pName))
  
  #Add Metadata
  MD=Add_Metadata()
  P_Master=st_set_geometry(MD,st_geometry(P_Master))
  P_Clipped=st_set_geometry(MD,st_geometry(P_Clipped))
  
  #Export
  Export_Pol(Fname=paste0("RB_",pName))
  
  message(paste0(pName," in ",sName," done."))
}



gc()