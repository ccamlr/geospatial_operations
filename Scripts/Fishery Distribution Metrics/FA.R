#Fished Areas function
#Script to 'rasterize' data, determine classes of cumulated catch,
#then use these classes to build polygons from contours
library(CCAMLRGIS)
library(terra)
library(smoothr)

#Parameters:
#Input: Input dataframe containing the fields Latitude, Longitude, Catch (exact spelling).
#Plot: either NULL (no plot), or path to the folder in which a plot should be exported to (e.g., "C:/Science/Project")
#PlotName: if a plot is desired, this is the name of the resulting file (e.g., "MyPlot").
#PlotTitle: if a plot is desired, this is its title on the figure (set to NULL for no title).
#Res: Target resolution of the gridded data in meters.
#Qs: Quantiles of cumulated catch, used to build catch classes.
#TQ: Target quantile above which cells of gridded catch are pooled and contoured.
#smoo: smoothing parameter (see ?smooth_ksmooth).
#ID: if desired, an identifier may be added in the resulting spatial object (useful if this function is used inside a loop).

FA=function(Input,Plot=NULL,PlotName=NULL,PlotTitle=NULL,Res=10000,Qs=c(0,0.25,0.5,0.75,1),TQ=0.5,smoo=1,ID=NA){
  #Check for input errors
  if(all(c("Latitude","Longitude","Catch")%in%colnames(Input))==FALSE){stop("Check Input columns and their names.")}
  if(is.null(Plot)==FALSE & is.null(PlotName)==TRUE){stop("If 'Plot' is not NULL, a 'PlotName' is required.")}
  
  #Prepare plot if desired
  if(is.null(Plot)==FALSE){
    png(filename=paste0(Plot,"/",PlotName,".png") , width = 2000, height = 2800,
        units = "px", pointsize = 12,bg = "white", res = 200)
    par(mfrow=c(3,2),mai=c(0.55,0.55,1,0.3),mgp=c(1.2,0.2,0),
        xaxs="i",yaxs="i",lend=1,cex=1.25,tcl=-0.2)
  }
  
  #Project locations
  D=project_data(Input,NamesIn=c("Latitude","Longitude"))
  
  #Step 1. Check frequency distribution of Catch
  if(is.null(Plot)==FALSE){
  h=hist(D$Catch,40,plot=FALSE)
  plot(h,main="1. Frequency distribution of catch",
       xlab="Catch",xpd=TRUE)
  text(min(h$mids),max(h$counts),PlotTitle,xpd=TRUE,cex=1.75,font=2,adj=c(0.1,-2.6))
  }
  
  #Step 2. Grid the data (ie 'rasterize') and compute the sum of catch per grid cell
  #Prepare an empty raster
  Ext=ext(min(D$X)-Res,max(D$X)+Res,min(D$Y)-Res,max(D$Y)+Res) #Set extent of raster
  r=rast(Ext,resolution=Res,crs="EPSG:6932")
  #Compute sum of catch per raster cell
  r=rasterize(x=D[,c("X","Y")],y=r,values=D$Catch,fun="sum")
  if(is.null(Plot)==FALSE){
  #Check raster
  plot(r,plg=list(title="Sum of catch"),main="2. Raster",
       xlim=range(D$X),ylim=range(D$Y),axes=FALSE)
  plot(st_geometry(Coast[Coast$ID=='All',]),col='grey',add=TRUE)
  }
  
  #Step 3. Compute catch classes (Cclasses)
  #Get Cumulative catch proportions after ordering cells by their catch
  #Extract per-cell catch values from the raster and sort them
  vs=sort(values(r,mat=FALSE,na.rm=TRUE)) 
  #Store in a dataframe and compute normalized cumulative sum (0-1)
  Vs=data.frame(x=cumsum(vs)/sum(vs),y=vs) 
  #Interpolate between values to get the target Quantiles (Qs)
  Int=approx(x=Vs$x,y=Vs$y,xout=Qs,ties="ordered")
  Int$y[1]=0 #Lowest bound of catch is zero
  Cclasses=Int$y #Catch classes
  
  #3a. Check classes
  if(is.null(Plot)==FALSE){
  plot(Vs$y,Vs$x*100,main="3a. Cumulated catch proportion",
       xlab="Catch per grid cell",ylab="Proportion of catch (%)",
       pch=21,bg="black",cex=0.75,bty="n",type="b")
  points(Int$y,Int$x*100,pch=21,bg="red",cex=1.5,xpd=TRUE)
  text(Int$y,Int$x*100,paste0(Int$x*100,"%"),col="red",cex=1,xpd=TRUE,adj=c(1.2,0.5))
  text(Int$y,Int$x*100,round(Int$y),col="red",cex=1,xpd=TRUE,adj=c(1.2,0.5),srt=90)
  }
  
  #3b. Check classes against the distribution of catch in cells
  if(is.null(Plot)==FALSE){
  h=hist(r,breaks=50,plot=FALSE)
  #colorize classes
  Cols=add_col(h$mids,Int$y,cols=hcl.colors(n=4, palette = "viridis"))
  plot(h$mids,h$counts,type="h",main="3b. Distribution of catch in cells",
       xlab="Catch per grid cell",ylab="Frequency",
       col=Cols$varcol,lwd=8,xpd=TRUE,bty="n")
  text(Cclasses,max(h$counts),paste0(Int$x*100,"%"),col="red",adj=c(0.5,0.5),cex=1,xpd=TRUE)
  abline(v=Cclasses,lwd=0.5,col="red",lty=2)
  }
  
  #Step 4. Build polygons from contours of chosen classes
  Pcont=st_as_sf(as.polygons(classify(r,Cclasses,brackets=FALSE)))
  Pcont$c=hcl.colors(n=length(Cclasses)-1,palette="viridis")
  if(is.null(Plot)==FALSE){
  #Check polygons
  plot(st_geometry(Pcont),col=Pcont$c,main="4. Polygonized contours",
       xlim=range(D$X),ylim=range(D$Y))
  plot(st_geometry(Coast[Coast$ID=='All',]),col='grey',add=TRUE)
  }
  
  #Step 5. Isolate upper target quantile (TQ) of the catch
  #Isolate corresponding layers 
  Tlayers=Pcont[seq(which(Qs==TQ),nrow(Pcont)),]
  #Merge into one polygon and smooth it
  Outp=st_union(Tlayers)
  Outp=smooth(Outp,method="ksmooth",smoothness=smoo)
  if(is.null(Plot)==FALSE){
  plot(st_geometry(Tlayers),col=Tlayers$c,
       border=NA,main=paste0("5. Upper ",TQ*100,"% of the catch (smoothed)"),
       xlim=range(D$X),ylim=range(D$Y))
  plot(Outp,border="red",add=TRUE,lwd=3)
  plot(st_geometry(Coast[Coast$ID=='All',]),col='grey',add=TRUE)
  #Export plot
  dev.off()
  }
  
  #Build spatial object and return
  Outp=st_set_geometry(data.frame(ID=ID),Outp)
  return(Outp)
}
