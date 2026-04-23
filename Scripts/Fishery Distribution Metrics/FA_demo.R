#Fished Areas demo with simulated data

#Load Fished Areas function
source("Scripts/Fishery Distribution Metrics/FA.R")


#Generate some data, for two fished areas
N=5000 #Number of records per zone
D1=data.frame( #Zone 1
  Latitude=rnorm(n=N,mean=-63,sd=3),
  Longitude=rnorm(n=N,mean=-60,sd=3),
  Catch=rnorm(n=N,mean=100,sd=2) 
)
D2=data.frame( #Zone 2
  Latitude=rnorm(n=N,mean=-60,sd=1.5),
  Longitude=rnorm(n=N,mean=-46,sd=1.5),
  Catch=rnorm(n=N,mean=80,sd=4) 
)
#Combine records
Input=rbind(D1,D2)

#Run without plotting
P1=FA(Input)

#Run with plotting
P2=FA(Input,
      Plot=paste0(getwd(),"/Figures"),
      PlotName="FA_Demo",
      PlotTitle="Testing Fished Areas")

#Plot the output alone
plot(st_geometry(P2),col="cyan")
plot(st_geometry(Coast[Coast$ID=='All',]),col='grey',add=T)
