#Script to build/update Master Vertices


#Set the name of this script
sName="CEMP_Step1_Vertices.R"


CEMP=ccamlrtools::queryccamlr('select * from site_codes', asis = F)%>%
  dplyr::filter(ONLINE_GIS_YN == 'Y')%>%select(Latitude=LATITUDE,Longitude=LONGITUDE,Name=SITE_CODE)




message(paste0(sName," done."))
gc()