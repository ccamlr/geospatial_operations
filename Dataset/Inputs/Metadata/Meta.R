library(dplyr)

Pth="I:/Science/Projects/Geospatial Operations/GIS Workflow/Polygon Builder/Inputs/Metadata/"

OK=read.csv(paste0(Pth,"Core_Geospatial_Metadata_Ex.csv"))
Add=read.csv(paste0(Pth,"layer_metadata.csv"))

Add$ID[Add$ID%in%OK$ID==F]
N=Add%>%group_by(ID)%>%summarise(n=n())
OK$ID[OK$ID%in%Add$ID==F & OK$Class%in%c("CEMP","VME")==F] # Only missing CEMP and VME

Tmp=left_join(OK,Add,by="ID")
Tmp=Tmp%>%filter(Class%in%c("CEMP","VME")==F)
Chck=Tmp[which(Tmp$Active!=Tmp$Active_raw),]
