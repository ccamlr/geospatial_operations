#Script to build/update Master Vertices

#This script does all SSRUs at once, not per-polygon like the others
#NB: secondary vertices to match SSRUs with SSRUs and with ASDs may need to be added in the future.


#Set the name of this script
sName="SSRUs_Step1_Vertices.R"



#The rest should be automatic

#Load Helpers
source("Dataset/Scripts/Z_Helpers.R")

#List SSRUs
ssrus=c('486A','486B','486C','486D','486E','486F','486G',
        '5841A','5841B','5841C','5841D','5841E','5841F','5841G','5841H',
        '5842A','5842B','5842C','5842D','5842E',
        '5843aA','5843bA','5843bB','5843bC','5843bD','5843bE',
        '5844aA','5844aB','5844aD','5844bB','5844bC','5844bD',
        '586B','586C','586D',
        '587A','587B',
        '881A','881B','881C','881D','881E','881F','881G','881H','881I','881J','881K','881L','881M',
        '882A','882B','882C','882D','882E','882F','882G','882H','882I',
        '883A','883B','883C','883D')


# pName='882C'

for(pName in ssrus){
  
  
  #1. Load Vertices
  Vs=Load_Vs()
  PV=Vs$PV #Primary Vertices
  IV=Vs$IV #Inland Vertices
  SV=Vs$SV #Secondary Vertices
  MV=Vs$MV #Master Vertices
  rm(Vs)
  
  if(pName%in%c('486B','486C','486D','486E','486F', #Special cases requiring inland vertices
                '5841B','5841C','5841D','5841E','5841F','5841G','5841H',
                '5842A','5842B','5842C','5842D','5842E',
                '881D','881F','881M',
                '882B','882C','882D','882E','882F','882G',
                '883A','883B','883C','883D'))
  { 
    
    
    if(pName=="486B"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I38-I39
      #I38 to I35
      #S10
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I38"],IV$Latitude[IV$Vertex=="I38"],
                                     IV$Longitude[IV$Vertex=="I39"],IV$Latitude[IV$Vertex=="I39"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S53"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S53"),(1:3)],
        IV[which(IV$Vertex=="I38"):which(IV$Vertex=="I35"),(1:3)],
        SV[which(SV$Vertex=="S10"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="486C"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I41-I42 (to be S54)
      #I41 to I39
      #S53
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I41"],IV$Latitude[IV$Vertex=="I41"],
                                     IV$Longitude[IV$Vertex=="I42"],IV$Latitude[IV$Vertex=="I42"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S54"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S54"),(1:3)],
        IV[which(IV$Vertex=="I41"):which(IV$Vertex=="I39"),(1:3)],
        SV[which(SV$Vertex=="S53"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="486D"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I43-I44 (to be S55)
      #I43 to I42
      #S54
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I43"],IV$Latitude[IV$Vertex=="I43"],
                                     IV$Longitude[IV$Vertex=="I44"],IV$Latitude[IV$Vertex=="I44"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S55"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S55"),(1:3)],
        IV[which(IV$Vertex=="I43"):which(IV$Vertex=="I42"),(1:3)],
        SV[which(SV$Vertex=="S54"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="486E"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I47-I48 (to be S56)
      #I47 to I44
      #S55
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I47"],IV$Latitude[IV$Vertex=="I47"],
                                     IV$Longitude[IV$Vertex=="I48"],IV$Latitude[IV$Vertex=="I48"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S56"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S56"),(1:3)],
        IV[which(IV$Vertex=="I47"):which(IV$Vertex=="I44"),(1:3)],
        SV[which(SV$Vertex=="S55"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="486F"){
      
      ##Plan##
      #P1, P2
      #S13
      #I49 to I48
      #S56
      
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S13"),(1:3)],
        IV[which(IV$Vertex=="I49"):which(IV$Vertex=="I48"),(1:3)],
        SV[which(SV$Vertex=="S56"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="5841B"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I75-I76 (to be S57)
      #I75
      #S26
      #P5, P6
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I75"],IV$Latitude[IV$Vertex=="I75"],
                                     IV$Longitude[IV$Vertex=="I76"],IV$Latitude[IV$Vertex=="I76"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S57"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S57"),(1:3)],
        IV[which(IV$Vertex=="I75"),(1:3)],
        SV[which(SV$Vertex=="S26"),(1:3)],
        PV[which(PV$Vertex=="P5"):which(PV$Vertex=="P6"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="5841C"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I78-I79 (to be S58)
      #I78-I76
      #S57
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I78"],IV$Latitude[IV$Vertex=="I78"],
                                     IV$Longitude[IV$Vertex=="I79"],IV$Latitude[IV$Vertex=="I79"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S58"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S58"),(1:3)],
        IV[which(IV$Vertex=="I78"):which(IV$Vertex=="I76"),(1:3)],
        SV[which(SV$Vertex=="S57"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="5841D"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I80-I81 (to be S59)
      #I80-I79
      #S58
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I80"],IV$Latitude[IV$Vertex=="I80"],
                                     IV$Longitude[IV$Vertex=="I81"],IV$Latitude[IV$Vertex=="I81"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S59"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S59"),(1:3)],
        IV[which(IV$Vertex=="I80"):which(IV$Vertex=="I79"),(1:3)],
        SV[which(SV$Vertex=="S58"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="5841E"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I86-I87 (to be S60)
      #I86-I81
      #S59
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I86"],IV$Latitude[IV$Vertex=="I86"],
                                     IV$Longitude[IV$Vertex=="I87"],IV$Latitude[IV$Vertex=="I87"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S60"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S60"),(1:3)],
        IV[which(IV$Vertex=="I86"):which(IV$Vertex=="I81"),(1:3)],
        SV[which(SV$Vertex=="S59"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="5841F"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I89-I90 (to be S61)
      #I89-I87
      #S60
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I89"],IV$Latitude[IV$Vertex=="I89"],
                                     IV$Longitude[IV$Vertex=="I90"],IV$Latitude[IV$Vertex=="I90"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S61"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S61"),(1:3)],
        IV[which(IV$Vertex=="I89"):which(IV$Vertex=="I87"),(1:3)],
        SV[which(SV$Vertex=="S60"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="5841G"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I91-I92 (to be S62)
      #I91-I90
      #S61
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I91"],IV$Latitude[IV$Vertex=="I91"],
                                     IV$Longitude[IV$Vertex=="I92"],IV$Latitude[IV$Vertex=="I92"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S62"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S62"),(1:3)],
        IV[which(IV$Vertex=="I91"):which(IV$Vertex=="I90"),(1:3)],
        SV[which(SV$Vertex=="S61"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="5841H"){
      
      ##Plan##
      #P1, P2
      #S17
      #I95-I92
      #S62
      
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S17"),(1:3)],
        IV[which(IV$Vertex=="I95"):which(IV$Vertex=="I92"),(1:3)],
        SV[which(SV$Vertex=="S62"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="5842A"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I51-I52 (to be S63)
      #I51-I50
      #S13
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I51"],IV$Latitude[IV$Vertex=="I51"],
                                     IV$Longitude[IV$Vertex=="I52"],IV$Latitude[IV$Vertex=="I52"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S63"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S63"),(1:3)],
        IV[which(IV$Vertex=="I51"):which(IV$Vertex=="I50"),(1:3)],
        SV[which(SV$Vertex=="S13"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="5842B"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I54-I55 (to be S64)
      #I54-I52
      #S63
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I54"],IV$Latitude[IV$Vertex=="I54"],
                                     IV$Longitude[IV$Vertex=="I55"],IV$Latitude[IV$Vertex=="I55"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S64"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S64"),(1:3)],
        IV[which(IV$Vertex=="I54"):which(IV$Vertex=="I52"),(1:3)],
        SV[which(SV$Vertex=="S63"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="5842C"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I62-I63 (to be S65)
      #I62-I56
      #S64
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I62"],IV$Latitude[IV$Vertex=="I62"],
                                     IV$Longitude[IV$Vertex=="I63"],IV$Latitude[IV$Vertex=="I63"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S65"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S65"),(1:3)],
        IV[which(IV$Vertex=="I62"):which(IV$Vertex=="I56"),(1:3)],
        SV[which(SV$Vertex=="S64"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="5842D"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I70-I71 (to be S66)
      #I70-I63
      #S65
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I70"],IV$Latitude[IV$Vertex=="I70"],
                                     IV$Longitude[IV$Vertex=="I71"],IV$Latitude[IV$Vertex=="I71"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S66"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S66"),(1:3)],
        IV[which(IV$Vertex=="I70"):which(IV$Vertex=="I63"),(1:3)],
        SV[which(SV$Vertex=="S65"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="5842E"){
      
      ##Plan##
      #P1 to P4
      #Intersection P4-P5 and I74-I75 (to be S67)
      #I74-I71
      #S66
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P4"],PV$Latitude[PV$Vertex=="P4"],
                                     PV$Longitude[PV$Vertex=="P5"],PV$Latitude[PV$Vertex=="P5"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I74"],IV$Latitude[IV$Vertex=="I74"],
                                     IV$Longitude[IV$Vertex=="I75"],IV$Latitude[IV$Vertex=="I75"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S67"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P4"),(1:3)],
        SV[which(SV$Vertex=="S67"),(1:3)],
        IV[which(IV$Vertex=="I74"):which(IV$Vertex=="I71"),(1:3)],
        SV[which(SV$Vertex=="S66"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="881D"){
      
      ##Plan##
      #P1, P2
      #Intersection P2-P3 and I97-I98 (to be S68)
      #I97-I96
      #S17
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I97"],IV$Latitude[IV$Vertex=="I97"],
                                     IV$Longitude[IV$Vertex=="I98"],IV$Latitude[IV$Vertex=="I98"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S68"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S68"),(1:3)],
        IV[which(IV$Vertex=="I97"):which(IV$Vertex=="I96"),(1:3)],
        SV[which(SV$Vertex=="S17"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="881F"){
      
      ##Plan##
      #P1 to P3
      #Intersection P3-P4 and I103-I104 (to be S69)
      #I103-I98
      #S68
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"],
                                     PV$Longitude[PV$Vertex=="P4"],PV$Latitude[PV$Vertex=="P4"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I103"],IV$Latitude[IV$Vertex=="I103"],
                                     IV$Longitude[IV$Vertex=="I104"],IV$Latitude[IV$Vertex=="I104"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S69"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P3"),(1:3)],
        SV[which(SV$Vertex=="S69"),(1:3)],
        IV[which(IV$Vertex=="I103"):which(IV$Vertex=="I98"),(1:3)],
        SV[which(SV$Vertex=="S68"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="881M"){
      
      ##Plan##
      #P2 to P3
      #Intersection P3-P4 and I108-I109 (to be S70)
      #I108-I104
      #S69
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"],
                                     PV$Longitude[PV$Vertex=="P4"],PV$Latitude[PV$Vertex=="P4"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I108"],IV$Latitude[IV$Vertex=="I108"],
                                     IV$Longitude[IV$Vertex=="I109"],IV$Latitude[IV$Vertex=="I109"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S70"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P2"):which(PV$Vertex=="P3"),(1:3)],
        SV[which(SV$Vertex=="S70"),(1:3)],
        IV[which(IV$Vertex=="I108"):which(IV$Vertex=="I104"),(1:3)],
        SV[which(SV$Vertex=="S69"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="882B"){
      
      ##Plan##
      #P1-P2
      #Intersection P2-P3 and I125-I124 (to be S71)
      #I124-I118
      #P4
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I125"],IV$Latitude[IV$Vertex=="I125"],
                                     IV$Longitude[IV$Vertex=="I124"],IV$Latitude[IV$Vertex=="I124"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S71"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S71"),(1:3)],
        IV[which(IV$Vertex=="I124"):which(IV$Vertex=="I118"),(1:3)],
        PV[which(PV$Vertex=="P4"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="882C"){
      
      ##Plan##
      #P1-P2
      #Intersection P2-P3 and I128-I127 (to be S72)
      #I127-I125
      #S71
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I128"],IV$Latitude[IV$Vertex=="I128"],
                                     IV$Longitude[IV$Vertex=="I127"],IV$Latitude[IV$Vertex=="I127"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S72"
      )
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P1"],PV$Latitude[PV$Vertex=="P1"],
                                     PV$Longitude[PV$Vertex=="P4"],PV$Latitude[PV$Vertex=="P4"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I122"],IV$Latitude[IV$Vertex=="I122"],
                                     IV$Longitude[IV$Vertex=="I123"],IV$Latitude[IV$Vertex=="I123"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=rbind(SVtmp,data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S73")
      )
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P1"],PV$Latitude[PV$Vertex=="P1"],
                                     PV$Longitude[PV$Vertex=="P4"],PV$Latitude[PV$Vertex=="P4"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I121"],IV$Latitude[IV$Vertex=="I121"],
                                     IV$Longitude[IV$Vertex=="I120"],IV$Latitude[IV$Vertex=="I120"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=rbind(SVtmp,data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S74")
      )
      
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S72"),(1:3)],
        IV[which(IV$Vertex=="I127"):which(IV$Vertex=="I125"),(1:3)],
        SV[which(SV$Vertex=="S71"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="882D"){
      
      ##Plan##
      #P1-P2
      #Intersection P2-P3 and I131-I130 (to be S75)
      #I130-I128
      #S72
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I131"],IV$Latitude[IV$Vertex=="I131"],
                                     IV$Longitude[IV$Vertex=="I130"],IV$Latitude[IV$Vertex=="I130"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S75"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S75"),(1:3)],
        IV[which(IV$Vertex=="I130"):which(IV$Vertex=="I128"),(1:3)],
        SV[which(SV$Vertex=="S72"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="882E"){
      
      ##Plan##
      #P1-P2
      #Intersection P2-P3 and I131-I130 (to be S76)
      #S75
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I131"],IV$Latitude[IV$Vertex=="I131"],
                                     IV$Longitude[IV$Vertex=="I130"],IV$Latitude[IV$Vertex=="I130"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S76"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S76"),(1:3)],
        SV[which(SV$Vertex=="S75"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="882F"){
      
      ##Plan##
      #P1-P2
      #Intersection P2-P3 and I132-I133 (to be S77)
      #I132-I131
      #S76
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I132"],IV$Latitude[IV$Vertex=="I132"],
                                     IV$Longitude[IV$Vertex=="I133"],IV$Latitude[IV$Vertex=="I133"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S77"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S77"),(1:3)],
        IV[which(IV$Vertex=="I132"):which(IV$Vertex=="I131"),(1:3)],
        SV[which(SV$Vertex=="S76"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="882G"){
      
      ##Plan##
      #P1-P2
      #S23
      #S77
      
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S23"),(1:3)],
        SV[which(SV$Vertex=="S77"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="883A"){
      
      #P1-P2
      #Intersection P2-P3 and I136-I137 (to be S78)
      #I136-I133
      #S23
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I136"],IV$Latitude[IV$Vertex=="I136"],
                                     IV$Longitude[IV$Vertex=="I137"],IV$Latitude[IV$Vertex=="I137"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S78"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S78"),(1:3)],
        IV[which(IV$Vertex=="I136"):which(IV$Vertex=="I133"),(1:3)],
        SV[which(SV$Vertex=="S23"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="883B"){
      
      #P1-P2
      #Intersection P2-P3 and I137-I138 (to be S79)
      #I137
      #S78
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I137"],IV$Latitude[IV$Vertex=="I137"],
                                     IV$Longitude[IV$Vertex=="I138"],IV$Latitude[IV$Vertex=="I138"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S79"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S79"),(1:3)],
        IV[which(IV$Vertex=="I137"),(1:3)],
        SV[which(SV$Vertex=="S78"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="883C"){
      
      #P1-P2
      #Intersection P2-P3 and I140-I141 (to be S80)
      #I140-I138
      #S79
      
      #2. Generate Secondary vertices and verify they are the same as loaded
      tmp=get_C_intersection(Line1=c(PV$Longitude[PV$Vertex=="P2"],PV$Latitude[PV$Vertex=="P2"],
                                     PV$Longitude[PV$Vertex=="P3"],PV$Latitude[PV$Vertex=="P3"]),
                             Line2=c(IV$Longitude[IV$Vertex=="I140"],IV$Latitude[IV$Vertex=="I140"],
                                     IV$Longitude[IV$Vertex=="I141"],IV$Latitude[IV$Vertex=="I141"]),Plot=F)
      tmp=round(tmp,2)
      SVtmp=data.frame(
        Latitude=as.numeric(tmp['Lat']),
        Longitude=as.numeric(tmp['Lon']),
        Vertex="S80"
      )
      #Check identity
      if(identical(SV%>%filter(Vertex%in%SVtmp$Vertex),SVtmp)==F){stop(paste0("Mismatch in Secondary Vertices in ",sName))}
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S80"),(1:3)],
        IV[which(IV$Vertex=="I140"):which(IV$Vertex=="I138"),(1:3)],
        SV[which(SV$Vertex=="S79"),(1:3)]
      )
      MVtmp$Name=pName
      # write.csv(MVtmp,paste0(Root,"/Master Vertices/tmp.csv"))
      # qq=create_Polys(MV[,c(4,1,2)]);plot(st_geometry(qq),col="green");plot(st_geometry(SSRUs),add=T,border="red")
    }
    
    if(pName=="883D"){
      
      #P1-P2
      #S5-S1
      #S80
      
      #3. Build Master vertices and verify they are the same as loaded
      MVtmp=bind_rows(
        PV[which(PV$Vertex=="P1"):which(PV$Vertex=="P2"),(1:3)],
        SV[which(SV$Vertex=="S5"):which(SV$Vertex=="S1"),(1:3)],
        SV[which(SV$Vertex=="S80"),(1:3)]
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
