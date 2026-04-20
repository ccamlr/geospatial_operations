#Script containing helper functions, sourced by other scripts
library(CCAMLRGIS)
library(dplyr)

#Set the root folder
Root=paste0(getwd(),"/Dataset/")

#Function to load vertices
#Types are:
#"P": Primary vertices
#"I": Inland vertices
#"S": Secondary vertices
#"M": Master vertices
#pname is the polygon name, required to identify Primary and Master vertices 
#sname is the name of the R script that called this function. Required for error messages
Load_Vs=function(Type=c("P","I","S","M"),root=Root,pname=pName,sname=sName){
  #Check script name has been given
  if(is.null(sname)){stop("Load_Vs() requires the name of the script from which it was called.")}
  #"P": Primary vertices
  PV=NULL
  if("P"%in%Type){
    if(is.null(pname)){stop(paste0("Primary vertices require a pName in ",sname))}
    PV=read.csv(paste0(root,"Inputs/Primary_Vertices.csv"))
    PV=PV%>%filter(Name==pname)
  }
  #"I": Inland vertices
  IV=NULL
  if("I"%in%Type){
    IV=read.csv(paste0(root,"Inputs/Inland_Vertices_V3.csv"))
  }
  #"S": Secondary vertices
  SV=NULL
  if("S"%in%Type){
    SV=read.csv(paste0(root,"Inputs/Secondary_Vertices.csv"))
  }
  #"M": Master vertices
  MV=NULL
  if("M"%in%Type){
    if(is.null(pname)){stop(paste0("Master vertices require a pName in ",sname))}
    MV=read.csv(paste0(root,"Inputs/Master_Vertices.csv"))
    MV=MV%>%filter(Name==pname)
    MV$Name=as.character(MV$Name)
  }
  return(list(PV=PV,IV=IV,SV=SV,MV=MV))
}

#Function to plot master polygon
Plot_master=function(P_master=P_Master,mv=MV,bb=BB,root=Root,pname=pName,sname=sName,Fname=NULL){
  #Check polygon is valid
  if(any(st_is_valid(P_master)==F)){message(paste0(">>>>>>>>>>>>>>>>>> P_Master for ",pname," is not a valid polygon."))}
  if(is.null(Fname)){#Build filename automatically. Otherwise, do it manually (for script that build multiple polygons eg SSRUs)
    Fname=strsplit(sname,"_Step")[[1]][1]
  }
  Fname=paste0(root,"Plots/",Fname,"_P1-Master.png")
  #Build bounding box
  bx=st_as_sfc(bb)
  #Build points
  Ps=create_Points(mv)
  Ps$col="red"
  Ps$col[grep("P",Ps$Vertex)]="darkgreen"
  Ps$col[grep("S",Ps$Vertex)]="blue"
  
  tmpV=Ps$Vertex
  DegE=which(Ps$Longitude>0)
  if(length(DegE)>0){
    Ps$Vertex[DegE]=paste0(tmpV[DegE]," (",abs(Ps$Latitude[DegE]),"S|",abs(Ps$Longitude[DegE]),"E)")
  }
  DegW=which(Ps$Longitude<=0)
  if(length(DegW)>0){
    Ps$Vertex[DegW]=paste0(tmpV[DegW]," (",abs(Ps$Latitude[DegW]),"S|",abs(Ps$Longitude[DegW]),"W)")
  }
  
  png(filename=Fname,width=5000,height=5000,res=600)
  par(mai=rep(0.2,4),xaxs="i",yaxs="i")
  plot(bx,col='white',border='white')
  plot(st_geometry(coast),col='grey',border=NA,add=T)
  plot(st_geometry(P_master),add=T,lwd=0.5,col=rgb(0,1,0.1,alpha=0.5),border=rgb(0,1,0.1,alpha=0.5))
  add_RefGrid(bb=bb,ResLat = 1,ResLon = 1,lwd=0.1,fontsize = 0.5,LatR = c(-84, -45))
  plot(bx,lwd=2,add=T,xpd=T)
  plot(st_geometry(Ps),add=T,pch=4,cex=0.25,col=Ps$col,lwd=0.25)
  text(Ps$x,Ps$y,Ps$Vertex,adj=c(-0.1,0.5),col=Ps$col,xpd=T,cex=0.25)
  text(bb['xmin'],bb['ymax'],pname,adj=c(-0.1,1.1),xpd=T,cex=2,font=2)
  dev.off()
}

#Function to plot clipped polygon
Plot_clipped=function(P_clipped=P_Clipped,bb=BB,root=Root,pname=pName,sname=sName,Fname=NULL){
  #Check polygon is valid
  if(any(st_is_valid(P_clipped)==F)){message(paste0(">>>>>>>>>>>>>>>>>> P_Clipped for ",pname," is not a valid polygon."))}
  if(is.null(Fname)){#Build filename automatically. Otherwise, do it manually (for script that build multiple polygons eg SSRUs)
    Fname=strsplit(sname,"_Step")[[1]][1]
  }
  Fname=paste0(root,"Plots/",Fname,"_P2-Clipped.png")
  #Build bounding box
  bx=st_as_sfc(bb)
  
  png(filename=Fname,width=5000,height=5000,res=600)
  par(mai=rep(0.2,4),xaxs="i",yaxs="i")
  plot(bx,col='white',border='white')
  plot(st_geometry(P_clipped),col="darkgreen",lwd=0.1,add=T)
  text(bb['xmin'],bb['ymax'],pname,adj=c(-0.1,1.1),xpd=T,cex=2,font=2)
  dev.off()
}

#Function to add Metadata to objects, including label location
Add_Metadata=function(p_m=P_Master,p_c=P_Clipped,sname=sName,root=Root){
  #Read Metadata
  MD=read.csv(paste0(root,"Inputs/Core_Geospatial_Metadata.csv"),as.is=T)
  
  #1/2 Get label location
  Labs=NULL
  md_all=NULL
  for(i in seq(1,nrow(p_c))){
    P=p_c[i,]
    md=MD%>%filter(ID==P$ID)
    if(nrow(md)!=1){stop(paste0(">>>>>>>>>>>>>>>>>>>>>>>>>>> Metadata need attention in ",sname," for ",P$ID))}
    CL=md$Class
    GT=as.character(st_geometry_type(P))
    if(GT%in%c('POINT','LINESTRING','POLYGON','MULTIPOLYGON')==F){
      stop(paste0(">>>>>>>>>>>>>>>>>>>>>>>>>>> Label building is not ready for that geometry type, in ",sname))
    }
    #Point
    if(GT=='POINT'){
      Cen=st_coordinates(P)
      Cen=data.frame(Labx=Cen[1],Laby=Cen[2])
      Cen=project_data(Cen,NamesIn = c('Laby','Labx'),NamesOut = c('Lablat','Lablon'),inv = T)
      Cen$ID=P$ID
      Labs=rbind(Labs,Cen)
      md_all=rbind(md_all,md)
    }
    #Line
    if(GT=='LINESTRING'){
      Cen=st_line_sample(P,sample=0.5)
      Cen=st_coordinates(Cen)
      Cen=data.frame(Labx=Cen[1],Laby=Cen[2])
      Cen=project_data(Cen,NamesIn = c('Laby','Labx'),NamesOut = c('Lablat','Lablon'),inv = T)
      Cen$ID=P$ID
      Labs=rbind(Labs,Cen)
      md_all=rbind(md_all,md)
    }
    #Polygon
    if(GT%in%c('POLYGON','MULTIPOLYGON')){
      if(CL!="VME"){P=st_simplify(P, dTolerance=10000)}
      D=st_bbox(P)
      D=round(max(c(D['xmax']-D['xmin'],D['ymax']-D['ymin'])))
      alpha=-seq(D/100,D,length.out=40) #Series of distances to try
      n=1
      a=alpha[n]
      Empty=NULL
      while(st_is_empty(st_buffer(P,dist=a))==F){
        Empty=c(Empty,st_is_empty(st_buffer(P,dist=a)))
        n=n+1
        a=alpha[n]
      }
      Ps=st_buffer(P,dist=alpha[length(Empty)-1])
      Cen=suppressWarnings(st_centroid(Ps,of_largest_polygon=T))
      Cen=st_coordinates(Cen)
      Cen=data.frame(Labx=Cen[1],Laby=Cen[2])
      Cen=project_data(Cen,NamesIn = c('Laby','Labx'),NamesOut = c('Lablat','Lablon'),inv = T)
      Cen$ID=P$ID
      Labs=rbind(Labs,Cen)
      md_all=rbind(md_all,md)
    }
    
  }
  if(nrow(Labs)!=nrow(p_c)){stop(paste0(">>>>>>>>>>>>>>>>>>>>>>>>>>> Missing some labels in ",sname))}
  

  #2/2 format Metadata
  md_all=left_join(Labs,md_all,by="ID")
  md_all=md_all%>%select(ID,Class,Labx,Laby,Name,Class_long,Active,Version)
  md_all$Labx=round(md_all$Labx)
  md_all$Laby=round(md_all$Laby)
  return(md_all)
}

#Function to export polygons to the Outputs folder
Export_Pol=function(p_m=P_Master,p_c=P_Clipped,sname=sName,root=Root,Fname=NULL){
  if(is.null(Fname)){#Build filename automatically. Otherwise, do it manually (for script that build multiple polygons eg SSRUs)
    Fname=strsplit(sname,"_Step")[[1]][1]
  }
  Fname_m=paste0(root,"Outputs/",Fname,"_Master.gpkg")
  Fname_c=paste0(root,"Outputs/",Fname,"_Clipped.gpkg")
  #Write
  st_write(p_m,Fname_m,quiet=T,append=F,delete_dsn=T)
  st_write(p_c,Fname_c,quiet=T,append=F,delete_dsn=T)
}
