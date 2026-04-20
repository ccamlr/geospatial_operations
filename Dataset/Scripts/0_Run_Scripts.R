#Script to run all, or a selection of, scripts

#Set mode 
#Mode="All": Source all Vertices then all Polygons
#Mode can be set to run any script based on grep().
#eg Mode="ASD" will run all ASD scripts. Mode="486" will run all 486 scripts, etc...

Mode="All"


#The rest should be automatic

#Load Helpers
source("Dataset/Scripts/Z_Helpers.R")

#Load COAST for all scripts
COAST=load_Coastline()
COAST=COAST[COAST$surface=="Land",]
COAST=st_union(COAST)


#List scripts
Vscr=list.files(path=paste0(Root,"Scripts"),pattern="Step1",full.names=T) #Vertices
Pscr=list.files(path=paste0(Root,"Scripts"),pattern="Step2",full.names=T) #Objects

#Remove Blank scripts
Vscr=Vscr[-grep("00Blank",Vscr)]
Pscr=Pscr[-grep("00Blank",Pscr)]

#Build list of scripts to source based on chosen Mode
Rscr=NULL #list of scripts to run

if(Mode!="All"){
  Vscr=Vscr[grep(Mode,Vscr)]
  Pscr=Pscr[grep(Mode,Pscr)]
}
Rscr=c(Vscr,Pscr)

message("Start of scripts sourcing:")
message("--------------------------------")
#Source the list
for(i in seq(1,length(Rscr))){
  source(Rscr[i])
}
message("--------------------------------")
message("All scripts sourced succesfully.")
gc()

#Optional: send notification of completion
PBtext="Geospatial dataset completed."
source("I:/Science/Team/Stephane/PushBullet/PushBullet.R")
