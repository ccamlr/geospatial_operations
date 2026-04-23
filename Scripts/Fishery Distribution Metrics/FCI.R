#Fishery Concentration Index
#Script to build buffered lines from start/end locations of fishing events,
#compute their area and resulting Index (catch/area)

library(CCAMLRGIS)


#Parameters:
#Input: Input dataframe containing the fields Lat_Start, Lon_Start, Lat_End, Lon_End, Catch, Width (exact spelling).
#Width is the total width (meters) of a given fished footprint (buffered fished track from start to end location of fishing event).
#Width can be constant or set separately for each track.
#MergeB: logical (TRUE or FALSE), controls whether buffered tracks should be merged where they overlap. If set to TRUE,
#the area of the overlap of all tracks is counted only once.

FCI=function(Input,MergeB=FALSE){
  #Check for input errors
  if(all(c("Lat_Start", "Lon_Start", "Lat_End", "Lon_End", "Catch", "Width")%in%colnames(Input))==FALSE){stop("Check Input columns and their names.")}
 
  #Format input
  Tracks=data.frame(ID=rep(seq(1,nrow(Input)),2),
                    Lat=c(Input$Lat_Start,Input$Lat_End),
                    Lon=c(Input$Lon_Start,Input$Lon_End),
                    Width=rep(Input$Width,2))
  SEP_BUF=FALSE
  if(MergeB==FALSE){SEP_BUF=TRUE}
  Tracks=create_Lines(Tracks,
                      Buffer=Tracks$Width/(2*1852), #Half the width, in nautical miles
                      SeparateBuf=SEP_BUF)
  # #Optional: uncomment these two lines for a quick plot
  # plot(st_geometry(Tracks),col='cyan')
  # plot(st_geometry(Coast[Coast$ID=='All',]),col='grey',add=T) 
  
  #Compute area (in sq. km)
  ar=as.numeric(st_area(Tracks))/1e6
  ar=sum(ar) #Sum the area of each buffered track in case MergeB is FALSE
  
  Index=sum(Input$Catch)/ar
  return(Index)
}
