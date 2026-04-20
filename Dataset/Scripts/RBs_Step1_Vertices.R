#Script to build/update Master Vertices

#This script does all RBs at once, not per-polygon like others


#Set the name of this script
sName="RBs_Step1_Vertices.R"



#The rest should be automatic

#Load Helpers
source("Dataset/Scripts/Z_Helpers.R")

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
  


# pName='883_12'

for(pName in rbs){
  
  
  #1. Load Vertices
  Vs=Load_Vs()
  PV=Vs$PV #Primary Vertices
  IV=Vs$IV #Inland Vertices
  SV=Vs$SV #Secondary Vertices
  MV=Vs$MV #Master Vertices
  rm(Vs)
  
  if(pName%in%c('883_2','883_3','883_12'))#Special cases
  { 
    
    
    if(pName=="883_2"){
      
      ##Plan##
      #P1 - P6
      #P2 from 882_1 (becomes S81)
      
     #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P6"),(1:3)],
        SV[which(SV$Vertex=="S81"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="883_3"){
      
      ##Plan##
      #P1 - P6
      #P2 from 883_12 (becomes S82)
      
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P6"),(1:3)],
        SV[which(SV$Vertex=="S82"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="883_12"){
      
      ##Plan##
      #P1 - P2
      #P6 from 883_3 (becomes S83)
      #P3 - P4
      
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S83"),(1:3)],
        PV[which(PV$Vertex=="P3"):which(PV$Vertex=="P4"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
  }else{ #Not special cases (ie 'Primary Vertices' == 'Master Vertices')
    MVtmp=PV
    # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
  }
  
  #Check identity
  if(identical(MV,MVtmp)==F){stop(paste0("Mismatch in Master Vertices in ",sName))}
  
  message(paste0(pName," in ",sName," done."))
  
}

gc()
