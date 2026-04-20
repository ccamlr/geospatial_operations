#Script to build/update Master Vertices
library(dplyr)

#Set the name of this script
sName="VMEs_Step1_Vertices.R"


VMEs=ccamlrtools::queryccamlr('select * FROM [reporting].[dbo].[VME_REGISTRY]', asis = F)
VMEs=VMEs%>%select(Name=vme_id,geometry_type,latitude_min,latitude_max,longitude_min,longitude_max,latitude_mid,longitude_mid,buffer_size_nm)

RA=VMEs[grep("RA",VMEs$Name),]                                        #Risk Areas
FSR=VMEs[grep("FSR",VMEs$Name),]                                      #Fine Scale Rectangles
Reg=VMEs[grep("VME",VMEs$Name),]                                      #Registered VMEs
RegBP=Reg%>%filter(geometry_type=="point" & is.na(buffer_size_nm)==F) #Buffered Points
RegP=Reg%>%filter(geometry_type=="point" & is.na(buffer_size_nm)==T)  #Points
RegL=Reg%>%filter(geometry_type=="line_string")                       #Lines

if(nrow(Reg)!=sum(nrow(RegBP),nrow(RegP),nrow(RegL))){
  stop(paste0("VME class imbalance in ",sName))
}else{
  rm(Reg,VMEs)
}

message(paste0(sName," done."))
gc()