#Post process Results of flow calculations
#Read results
Res=read.csv(paste0("Outputs/",Pref,"_Results.csv"))
#Compute balances
chck=Res%>%
  group_by(ID,Suf)%>%
  summarise(Qmax=max(abs(Qe)),QT=sum(Qe),.groups='drop')%>%
  as.data.frame()
chck$P=100*abs(chck$QT/chck$Qmax)
write.csv(chck,paste0("Outputs/",Pref,"_Balances.csv"),row.names=F)
#Compute averages
Avg=Res%>%
  group_by(ID,Lat,Lon)%>%
  summarise(Qsd=sd(Qe),Qe=mean(Qe),.groups='drop')%>%
  as.data.frame()
write.csv(Avg,paste0("Outputs/",Pref,"_Averages.csv"),row.names=F)
