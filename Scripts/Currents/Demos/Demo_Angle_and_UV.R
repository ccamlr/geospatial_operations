#Demo of angle calculation

#Set vertices
A=c(1,2)
B=c(2,5)
C=c(5,4)
D=c(5,1.5)
E=c(2,1)
#build dataframe of vertices
df=data.frame(
  Lon=c(A[1],B[1],C[1],D[1],E[1],A[1]),
  Lat=c(A[2],B[2],C[2],D[2],E[2],A[2]),
  txt=c("A","B","C","D","E","")
)


#Velocity
U=0.35   #m/s
V=0.2 #m/s
dUV=sqrt(U^2+V^2)
Cen=c(3,3) #Start of Vel arrow
#Compute Vel arrow
beta=atan2(V,U)
Xv=Cen[1]+dUV*cos(beta)
Yv=Cen[2]+dUV*sin(beta)




png(filename="Scripts/Currents/Demos/Get_Angles_and_UV_CW.png",width=2000,height=2000,res=300)
par(mai=c(0.3,0.6,0,0.5),lend=1,xpd=T)

d=0.4 #Arbitrary length of arrows
plot(NA, xlim=range(df[,1]),ylim=range(df[,2]),xlab="",ylab="",asp=1,axes=F)
rect(xleft=min(df$Lon)-0.2,ybottom=min(df$Lat)-0.2,xright=max(df$Lon)+0.45,ytop=max(df$Lat)+0.2,col="cornflowerblue")
axis(1,pos=min(df$Lat)-0.2,labels = F)
axis(2,pos=min(df$Lon)-0.2,labels = F)
text(3,0.5,"Longitude",cex=2)
text(0.5,3,"Latitude",srt=90,cex=2)

#Plot velocity
arrows(x0=Cen[1],y0=Cen[1],x1=Cen[1]+U,y1=Cen[2],col="black",length = 0.1,lwd=2)
arrows(x0=Cen[1],y0=Cen[1],x1=Cen[1],y1=Cen[2]+V,col="black",length = 0.1,lwd=2)
arrows(x0=Cen[1],y0=Cen[1],x1=Xv,y1=Yv,col="blue",length = 0.1,lwd=2)
text(Cen[1]+U/2,Cen[2],"U",adj=c(0.5,1.3))
text(Cen[1],Cen[2]+V/2,"V",adj=c(1.8,0.5))

# For each polygon edge, get its centre and draw a perpenticular arrow
for(v in seq(1,nrow(df)-1)){
  #Get P1 and P2 (start and end vertices for a given edge)
  P1=c(df$Lon[v],df$Lat[v])
  P2=c(df$Lon[v+1],df$Lat[v+1])
  #compute edge centre
  Pc=c(mean(c(P1[1],P2[1])),mean(c(P1[2],P2[2])))
  #plot edge in red and its centre in blue
  segments(x0=P1[1],y0=P1[2],x1=P2[1],y1=P2[2],col="red",lwd=5)
  points(Pc[1],Pc[2],cex=2,col="blue",pch=21,bg="blue")
  #Compute angle of edge, relative to longitudes
  Theta=atan2(P2[2]-P1[2],P2[1]-P1[1])
  #remove pi/2 from Theta to get the perpendicular
  Alpha=Theta-pi/2
  #Compute new point as
  #perpendicular to edge (or at a Theta-pi/2 angle from the axis of longitudes)
  #and at a d distance away from it
  Xp=Pc[1]+d*cos(Alpha)
  Yp=Pc[2]+d*sin(Alpha)
  Pnew=c(Xp,Yp)
  #Plot orange arrow from edge centre to new point
  arrows(x0=Pc[1],y0=Pc[2],x1=Pnew[1],y1=Pnew[2],col="orange",length = 0.15,lwd=5)
  #Add projection of velocity
  Pmag=dUV*cos(Alpha-beta)
  if(Pmag>0){
    arrows(x0=Pc[1],y0=Pc[2],x1=Pc[1]+Pmag*cos(Alpha),y1=Pc[2]+Pmag*sin(Alpha),col="green",length = 0.1,lwd=2)
  }else{
    arrows(x0=Pc[1],y0=Pc[2],x1=Pc[1]+Pmag*cos(Alpha),y1=Pc[2]+Pmag*sin(Alpha),col="pink",length = 0.1,lwd=2)
  }
}
#Label vertices
points(df$Lon,df$Lat,pch=21,col="white",bg="white",cex=3.5)
text(df$Lon,df$Lat,df$txt,col="darkred",font=2,cex=1.5)

#legend
legend("topright",
       legend=c("Velocity","Edge normal","Positive flow","Negative flow"),
       inset=c(-0.068,0.054))
#Legend arrows
Xa=4.4
Xl=0.17
Ya=seq(5.05,4.58,length.out=4)
arrows(x0=Xa,y0=Ya[1],x1=Xa+Xl,y1=Ya[1],col="blue",length = 0.1,lwd=2)
arrows(x0=Xa,y0=Ya[2],x1=Xa+Xl,y1=Ya[2],col="orange",length = 0.12,lwd=4)
arrows(x0=Xa,y0=Ya[3],x1=Xa+Xl,y1=Ya[3],col="green",length = 0.1,lwd=2)
arrows(x0=Xa,y0=Ya[4],x1=Xa+Xl,y1=Ya[4],col="pink",length = 0.1,lwd=2)

dev.off()



df=df[(seq(nrow(df),1,by=-1)),] #flip vertices order to go counterclockwise



png(filename="Scripts/Currents/Demos/Get_Angles_and_UV_CCW.png",width=2000,height=2000,res=300)
par(mai=c(0.3,0.6,0,0.5),lend=1,xpd=T)

d=0.4 #Arbitrary length of arrows
plot(NA, xlim=range(df[,1]),ylim=range(df[,2]),xlab="",ylab="",asp=1,axes=F)
rect(xleft=min(df$Lon)-0.2,ybottom=min(df$Lat)-0.2,xright=max(df$Lon)+0.45,ytop=max(df$Lat)+0.2,col="cornflowerblue")
axis(1,pos=min(df$Lat)-0.2,labels = F)
axis(2,pos=min(df$Lon)-0.2,labels = F)
text(3,0.5,"Longitude",cex=2)
text(0.5,3,"Latitude",srt=90,cex=2)

#Plot velocity
arrows(x0=Cen[1],y0=Cen[1],x1=Cen[1]+U,y1=Cen[2],col="black",length = 0.1,lwd=2)
arrows(x0=Cen[1],y0=Cen[1],x1=Cen[1],y1=Cen[2]+V,col="black",length = 0.1,lwd=2)
arrows(x0=Cen[1],y0=Cen[1],x1=Xv,y1=Yv,col="blue",length = 0.1,lwd=2)
text(Cen[1]+U/2,Cen[2],"U",adj=c(0.5,1.3))
text(Cen[1],Cen[2]+V/2,"V",adj=c(1.8,0.5))

# For each polygon edge, get its centre and draw a perpenticular arrow
for(v in seq(1,nrow(df)-1)){
  #Get P1 and P2 (start and end vertices for a given edge)
  P1=c(df$Lon[v],df$Lat[v])
  P2=c(df$Lon[v+1],df$Lat[v+1])
  #compute edge centre
  Pc=c(mean(c(P1[1],P2[1])),mean(c(P1[2],P2[2])))
  #plot edge in red and its centre in blue
  segments(x0=P1[1],y0=P1[2],x1=P2[1],y1=P2[2],col="red",lwd=5)
  points(Pc[1],Pc[2],cex=2,col="blue",pch=21,bg="blue")
  #Compute angle of edge, relative to longitudes
  Theta=atan2(P2[2]-P1[2],P2[1]-P1[1])
  #remove pi/2 from Theta to get the perpendicular
  Alpha=Theta-pi/2
  #Compute new point as
  #perpendicular to edge (or at a Theta-pi/2 angle from the axis of longitudes)
  #and at a d distance away from it
  Xp=Pc[1]+d*cos(Alpha)
  Yp=Pc[2]+d*sin(Alpha)
  Pnew=c(Xp,Yp)
  #Plot orange arrow from edge centre to new point
  arrows(x0=Pc[1],y0=Pc[2],x1=Pnew[1],y1=Pnew[2],col="orange",length = 0.15,lwd=5)
  #Add projection of velocity
  Pmag=dUV*cos(Alpha-beta)
  if(Pmag>0){
    arrows(x0=Pc[1],y0=Pc[2],x1=Pc[1]+Pmag*cos(Alpha),y1=Pc[2]+Pmag*sin(Alpha),col="green",length = 0.1,lwd=2)
  }else{
    arrows(x0=Pc[1],y0=Pc[2],x1=Pc[1]+Pmag*cos(Alpha),y1=Pc[2]+Pmag*sin(Alpha),col="pink",length = 0.1,lwd=2)
  }
}
#Label vertices
points(df$Lon,df$Lat,pch=21,col="white",bg="white",cex=3.5)
text(df$Lon,df$Lat,df$txt,col="darkred",font=2,cex=1.5)
#legend
legend("topright",
       legend=c("Velocity","Edge normal","Positive flow","Negative flow"),
       inset=c(-0.068,0.054))
#Legend arrows
Xa=4.4
Xl=0.17
Ya=seq(5.05,4.58,length.out=4)
arrows(x0=Xa,y0=Ya[1],x1=Xa+Xl,y1=Ya[1],col="blue",length = 0.1,lwd=2)
arrows(x0=Xa,y0=Ya[2],x1=Xa+Xl,y1=Ya[2],col="orange",length = 0.12,lwd=4)
arrows(x0=Xa,y0=Ya[3],x1=Xa+Xl,y1=Ya[3],col="green",length = 0.1,lwd=2)
arrows(x0=Xa,y0=Ya[4],x1=Xa+Xl,y1=Ya[4],col="pink",length = 0.1,lwd=2)

dev.off()







