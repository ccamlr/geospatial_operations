#Fishery Concentration Index demo with simulated data

#Load Fished Areas function
source("Scripts/Fishery Distribution Metrics/FCI.R")


#Generate some data
N=20 #Number of lines
Input=data.frame(Lat_Start=rnorm(n=N,mean=-62,sd=1),
                 Lon_Start=rnorm(n=N,mean=-60,sd=1),
                 Lat_End=rnorm(n=N,mean=-62,sd=1),
                 Lon_End=rnorm(n=N,mean=-60,sd=1),
                 Catch=rnorm(n=N,mean=100,sd=3),
                 Width=runif(n=N,min=1000,max=10000)) #Width could be constant


#Run without merging tracks
FCI_1=FCI(Input)
FCI_1

#Run with merging tracks
FCI_2=FCI(Input,MergeB=T)
FCI_2
