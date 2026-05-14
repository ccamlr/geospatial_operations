#Fronts building script

#This scripts builds a Fronts polyline dataset from Park and Durand 2019
# Source:
# https://www.seanoe.org/data/00486/59800/
# Park Young-Hyang, Durand Isabelle (2019). Altimetry-drived Antarctic Circumpolar Current fronts. SEANOE. https://doi.org/10.17882/59800

#Version history:
# V1: Initial release
CCAMLRv="1"


library(CCAMLRGIS)
library(dplyr)
library(ncdf4)

#Give path to output folder
Pth="I:/Science/Projects/Geospatial Operations/GitHub/geospatial_operations/Dataset/External data/"


#1. Import raw data
Fr=nc_open(paste0(Pth,"Scripts/Inputs/Fronts/62985.nc"))
# print(Fr)
tmp=data.frame(
  ID="NB",
  Lat=ncvar_get(Fr, "LatNB"),
  Lon=ncvar_get(Fr, "LonNB"),
  Name="Northern boundary of the Antarctic Circumpolar Current"
)
tmp=rbind(tmp,
          data.frame(
            ID="SAF",
            Lat=ncvar_get(Fr, "LatSAF"),
            Lon=ncvar_get(Fr, "LonSAF"),
            Name="Subantarctic Front"
          )
)
tmp=rbind(tmp,
          data.frame(
            ID="PF",
            Lat=ncvar_get(Fr, "LatPF"),
            Lon=ncvar_get(Fr, "LonPF"),
            Name="Polar Front"
          )
)
tmp=rbind(tmp,
          data.frame(
            ID="SACCF",
            Lat=ncvar_get(Fr, "LatSACCF"),
            Lon=ncvar_get(Fr, "LonSACCF"),
            Name="Southern Antarctic Circumpolar Current Front"
          )
)
tmp=rbind(tmp,
          data.frame(
            ID="SB",
            Lat=ncvar_get(Fr, "LatSB"),
            Lon=ncvar_get(Fr, "LonSB"),
            Name="Southern boundary of the Antarctic Circumpolar Current"
          )
)
nc_close(Fr)

#Build lines
tmp=tmp%>%filter(is.na(tmp$Lon)==F)
Fronts=create_Lines(tmp)

tmp=tmp%>%group_by(ID)%>%summarise(Name=unique(Name))

Fronts=left_join(Fronts,tmp,by="ID")

Fronts$Version=CCAMLRv
Fronts$Source="doi.org/10.17882/59800"
                
  

if(any(st_is_valid(Fronts)==F)){stop("Fronts object is not valid.")}

#Export
st_write(Fronts, paste0(Pth,"Fronts.gpkg"),quiet=T,append=FALSE,delete_dsn=T)


#Optional: send notification of completion
PBtext="Fronts completed."
source("C:/Users/stephane/Desktop/CCAMLR/CODES/99 - PushBullet/PushBullet.R")
