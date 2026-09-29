#Functions for flow calculations


#Calculate_flow: calculate flow (in Sv) across each edge of polygon(s)
#Inputs are: 
###Pols: dataframe of vertices given one per row as: ID; Lat; Lon
###U: raster of eastward velocities from the model
###V: raster of northward velocities from the model
###Bm: raster of seafloor depths from the model
#Output is a dataframe with one row per edge and columns as:
###ID: the ID given in Pols
###Lat & Lon: location of edge centre
###Qe: Volumetric flow across that edge (in Sv), positive if going inward
Calculate_flow=function(Pols=Input,U=Umod,V=Vmod,Bm=Bmod){
  #Loop over edges within each polygon to get flow for each edge
  Extr=NULL #Prepare storage
  for(p in unique(Pols$ID)){ #Loop over polygons
    P=Pols[which(Pols$ID==p),] #Isolate vertices for that polygon
    #Close polygon if needed (when first and last row are not identical)
    if(identical(c(P[1,]),c(P[nrow(P),]))==F & nrow(P)>2){P=rbind(P,P[1,]);rownames(P)=NULL}
    #Loop over pairs of vertices to do each edge
    for(v in seq(1,nrow(P)-1)){ 
      #Get edge values, including the ID of each grid cell that was intersected by this edge
      EdgeVs=Get_edge_values(R=U,df=P[c(v,v+1),])
      #Isolate cell IDs for one of the layers (they are identical across layers)
      Cs=EdgeVs$Cs
      #Extract values from each layer using the cell IDs
      ikeep=NULL
      if(length(Cs)>0){
        Eu=extract(U,Cs,raw=T)
        Ev=extract(V,Cs,raw=T)
        EBm=extract(Bm,Cs,raw=T)
        ikeep=which(rowSums(Eu,na.rm=T)!=0)
      }
      #Get rid of missing point values (eg outside of depth range)
      if(length(ikeep)>0){
        Cs=Cs[ikeep]   
        Eu=Eu[ikeep,]
        Ev=Ev[ikeep,]
        EBm=EBm[ikeep,]
        Cl=EdgeVs$Cl[ikeep]
        #Ev and Eu are matrices of raw velocities from the model
        #Rows correspond to each cell that intersected this polygon edge 
        #Columns correspond to depths (as given in the dataframe headers and vector 'Ds')
        #You may check the matrices headers using eg: colnames(Eu)
        
        #Multiply velocities by the length of the portion of this edge that fell inside each cell
        #NB: in R, multiplying a matrix by a single vector as below results in multiplying each
        #column of the matrix by that vector.
        Eu=Eu*Cl
        Ev=Ev*Cl 
        
        #Next, each profile needs to be interpolated along depth
        
        #Run function
        GetDs=Get_depth_values(fEu=Eu,fEv=Ev,fBm=EBm,fDs=Ds,fDx=Dx)
        Iu=GetDs$Iu
        Iv=GetDs$Iv
        
        #Now Iu and Iv contain velocities for each depth, with a regular Di spacing
        
        #Compute angle of flow
        beta=atan2(Iv,Iu)
        
        #Compute magnitude of flow
        dUV=sqrt(Iu^2+Iv^2)
        
        #Project magnitude of velocity onto edge normal
        Pmag=dUV*cos(EdgeVs$alpha-beta)
        #Multiply by the height of depth intervals
        Pmag=Pmag*Di
        #Pmag is now the volumetric flow for each cell (velocity x width of cell x height of cell; in cubic meters)
        #Compute the total volumetric flow in Sverdrups:
        Q=sum(Pmag,na.rm=T)/1e6
        
        #Store results
        Extr=rbind(Extr,
                   data.frame(
                     ID=p,                  #Polygon ID
                     Lat=EdgeVs$Cen['Lat'],  #Lat of edge centre
                     Lon=EdgeVs$Cen['Lon'],  #Lon of edge centre
                     Qe=Q                    #Flow through that edge
                   )
        )
      }
    }
  }
  row.names(Extr)=NULL
  return(Extr)
}

#Get_edge_values: identify raster cells along a polygon edge or line segment.
#Inputs are:
###R: raster of interest
###df: dataframe with locations of edge extremities (columns: ID; Lat; Lon)
#Outputs are:
###Cs is a vector with cell identifiers,
###Cl is a vector of lengths (m) of each fraction of the edge that is inside each cell
###Cen is the location of the midpoint of the edge (used to plot arrows)
###alpha is the angle of the normal (perpendicular) to the edge
Get_edge_values=function(R,df){
  #Build edge as a georeferenced segment 
  L=st_sfc(st_linestring(cbind(df$Lon,df$Lat)),crs=4326) 
  #Get ID of grid cells intersecting that segment, along that segment (and in the right order)
  Cs=extractAlong(R,vect(L),cells=T)
  #Remove cell IDs where surface values are missing (eg beyond land mask)
  #NB: this will likely differ according to the model used, so should be checked.
  Cs=Cs$cell[is.na(Cs[,3])==F] 
  if(all(is.na(Cs))){
    return(list(Cs=NULL))
  }else{
    #Get Lat/Lon of cells centres
    xy=xyFromCell(R,Cs)
    #densify edge at twice the number of cells (ie ~twice the resolution)
    Dist=units::set_units(seq(0,1,by=1/(2*length(Cs))), degrees)
    L=suppressMessages(st_line_interpolate(L,dist=Dist,normalized=T))
    L=st_cast(st_combine(L),"LINESTRING") #Now the edge is a series of small segments
    #build a polygon cell around each point
    rg=res(R) #get resolution of grid
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
    if(nrow(cells)!=nrow(xy)){
      stop("Mismatch between the count of cells and the count of their centres, in Get_edge_values()")
    }
    #Turn the edge into a series of segments inside each cell
    Int=suppressWarnings(st_intersection(cells,L))
    # #Plot check
    # par(mai=rep(0.1,4))
    # plot(st_geometry(cells))
    # plot(st_geometry(L),add=T,col="red")
    # plot(st_geometry(Int),add=T,col="cyan")
    
    #If the edge is falling exactly on cell boundaries, shift it a tiny bit to avoid intersection error
    if(nrow(Int)!=nrow(cells)){ 
      L2=st_as_sf(L)
      st_geometry(L2)=st_geometry(L2)+c(1e-10,1e-10)
      st_crs(L2)=st_crs(L)
      Int=suppressWarnings(st_intersection(cells,L2))
    }
    #Redo the above if the shift was not in the right direction
    if(nrow(Int)!=nrow(cells)){ 
      L2=st_as_sf(L)
      st_geometry(L2)=st_geometry(L2)-c(1e-10,1e-10)
      st_crs(L2)=st_crs(L)
      Int=suppressWarnings(st_intersection(cells,L2))
    }
    #Get length of each segment
    Cl=as.numeric(st_length(Int))
    Cl=Cl[is.na(Cl)==F]
    #Check for error
    if(length(Cs)!=length(Cl)){
      stop("Mismatch between the count of cell indices and the count of their lengths, in Get_edge_values()")
    }
    #Compute edge centre
    Cen=c(Lat=mean(df$Lat),Lon=mean(df$Lon))
    #Compute angle of edge, relative to longitudes
    theta=atan2(df$Lat[2]-df$Lat[1],df$Lon[2]-df$Lon[1])
    #Compute angle of normal to edge
    alpha=theta-pi/2
    return(list(Cs=Cs,Cen=Cen,alpha=alpha,Cl=Cl))
  }
}



#Get_depth_values: interpolate extracted raster values along depth
#Inputs are: 3 matrices of extracted values (rows: points along a polygon edge; columns: fDs depth layers)
###fEu: U velocities
###fEv: V velocities
###fBm: bathymetry of the model
###fDs: mid-depths of model layers
###fDx: regularly spaced depths over which interpolation will occur
#Outputs are:
###Iu: matrix of U velocities (rows: points along a polygon edge; columns: fDx depths)
###Iv: matrix of V velocities (rows: points along a polygon edge; columns: fDx depths)
Get_depth_values=function(fEu=Eu,fEv=Ev,fBm=EBm,fDs=Ds,fDx=Dx){
  #Prepare storage of outputs
  Iu=matrix(NA,nrow=nrow(fEu),ncol=length(fDx))
  Iv=Iu
  #Loop over points, find lower limit of deepest layer (as given in fBm), and interpolate
  for(i in seq(1,nrow(fEu))){
    ds=fDs
    Eus=as.numeric(fEu[i,])   #U at each depth, for that point
    Evs=as.numeric(fEv[i,])   #V at each depth, for that point
    dbot=as.numeric(fBm[i])   #seafloor depth at that point
    #Remove values below seafloor
    iout=which(ds>dbot)
    if(length(iout)>0){
      Eus=Eus[-iout]  
      Evs=Evs[-iout]  
      ds=ds[-iout]
    }
    #Remove missing values if needed
    #(sometimes the deepest layer does not have values despite being shallower than the seafloor)
    iout=which(is.na(Eus)==T)
    if(length(iout)>0){
      Eus=Eus[-iout]  
      Evs=Evs[-iout]  
      ds=ds[-iout]
    }
    #linear regression of U over the two deepest layers
    vals=tail(Eus,2)
    deps=tail(ds,2)
    U_reg=lm(vals~deps) 
    #Extrapolate to dbot
    U_reg=predict(U_reg,data.frame(deps=dbot))
    #linear regression of V over the two deepest layers
    vals=tail(Evs,2)
    V_reg=lm(vals~deps) 
    #Extrapolate to dbot
    V_reg=predict(V_reg,data.frame(deps=dbot))
    # #Plot to check U
    # plot(ds,Eus,type="b",xlim=c(0,dbot+10),ylim=range(c(Eus,U_reg)),main="U")
    # abline(v=dbot,col="red")
    # points(dbot,U_reg,col="blue")
    # #Plot to check V
    # plot(ds,Evs,type="b",xlim=c(0,dbot+10),ylim=range(c(Evs,V_reg)),main="V")
    # abline(v=dbot,col="red")
    # points(dbot,V_reg,col="blue")
    
    #We have now U/V values for the deepest point
    #Let's append them to the existing series, at the end
    Eus=c(Eus,U_reg)
    Evs=c(Evs,V_reg)
    ds=c(ds,dbot)
    
    #Now repeat linear regressions to get the surface values
    #linear regression of U over the two shallowest layers
    vals=Eus[1:2]
    deps=ds[1:2]
    U_reg=lm(vals~deps)
    #Extrapolate to surface
    U_reg=predict(U_reg,data.frame(deps=0))
    #linear regression of V over the two shallowest layers
    vals=Evs[1:2]
    V_reg=lm(vals~deps)
    #Extrapolate to surface
    V_reg=predict(V_reg,data.frame(deps=0))
    
    #We have now U/V values for the surface
    #Let's append them to the existing series, at the beginning
    Eus=c(U_reg,Eus)
    Evs=c(V_reg,Evs)
    ds=c(0,ds)
    
    #Interpolate along Dx and store
    Iu[i,]=approx(x=ds,y=Eus,xout=Dx)$y 
    Iv[i,]=approx(x=ds,y=Evs,xout=Dx)$y 
  }
  #Return outputs
  return(list(Iu=Iu,Iv=Iv))
}



#Get_Polc: get polygon centres after clipping to the coastline (used for the arrows)
###Input df is formatted to work with create_Polys()
###Output is a dataframe with polygon ID, Lon and Lat 
Get_Polc=function(df){
  coast=load_Coastline()
  pol=create_Polys(Input)
  pol=suppressWarnings(st_difference(pol,st_union(coast)))
  Pcentres=suppressWarnings(st_centroid(pol))
  Pcentres=st_transform(Pcentres,4326)
  Pcentres=st_coordinates(Pcentres)
  Pcentres=data.frame(
    ID=pol$ID,
    Lon=Pcentres[,1],
    Lat=Pcentres[,2]
  )
  return(Pcentres)
}

#Simple_grid: generates a Lat/Lon grid of polygons
###Input df (Lat;Lon) gives the centres of grid cells
#if df is not given, a circumpolar grid is built 
Simple_grid=function(dlat,dlon,df=NULL){
  if(is.null(df)){
    Locs=expand.grid(Lat=seq(-85,-40,by=dlat),Lon=seq(-180+dlon/2,180-dlon/2,by=dlon))
  }else{
    Locs=df
  }
  Gr=NULL
  for(i in seq(1,nrow(Locs))){
    lat=Locs$Lat[i]
    lon=Locs$Lon[i]
    Gr=rbind(Gr,data.frame(
      ID=paste0("G_",i),
      Lat=c(lat+dlat/2,lat+dlat/2,lat-dlat/2,lat-dlat/2),
      Lon=c(lon-dlon/2,lon+dlon/2,lon+dlon/2,lon-dlon/2)
    ))
  }
  Gr$Lon[Gr$Lon<(-179.9)]=-179.9 #Stay way from antimeridian
  Gr$Lon[Gr$Lon>179.9]=179.9
  return(Gr)
}



#Arrow_Maker: builds arrows scaled to flow 
Arrow_Maker=function(extr=Extr,pcentres=Pcentres,fc=Fc){
  Arrs=NULL #Store arrows
  for(i in seq(1,nrow(extr))){
    #Get polygon centre
    LatC=pcentres$Lat[pcentres$ID==extr$ID[i]]
    LonC=pcentres$Lon[pcentres$ID==extr$ID[i]]
    #Prepare input dataframe
    InDF=data.frame(Lat=c(extr$Lat[i],LatC),Lon=c(extr$Lon[i],LonC))
    InDF=CCAMLRGIS:::DensifyData(Lon=InDF$Lon,Lat=InDF$Lat)
    InDF=data.frame(Lat=InDF[,2],Lon=InDF[,1])
    if(extr$Qe[i]<0){InDF=InDF[seq(nrow(InDF),1),]} #Flip orientation if flow is outwards
    fl=abs(extr$Qe[i])
    if(fl>0.000001){
      ar=create_Arrow(InDF,Pwidth = fl/fc,Hlength=fl/(fc/5),Hwidth=fl/(fc/3))
      ar$ID=extr$ID[i]
      ar$Suf=extr$Suf[i]
      Arrs=rbind(Arrs,ar)
    }
  }
  return(Arrs)
}
