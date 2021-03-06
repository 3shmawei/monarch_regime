######################################################
# Code for figures generated in harmonia case study
# adapted from Bahlai et al 2015 ecological applications
######################################################

#first, harmonia population data
#pre-process data as it was used in analysis
#read in raw data
harmonia<-read.csv(file="casestudydata/kbs_harmonia94-17.csv", header=T)
library(lubridate)

harmonia$newdate<-mdy(harmonia$DATE)
#extract year
harmonia$year<-year(harmonia$newdate)
#extract day of year
harmonia$doy<-yday(harmonia$newdate)

#because sampling periods varied year to year, sometimes with long tails,  let's cull the data at Aug 10

harmonia<-harmonia[which(harmonia$doy<222),]

#also get rid of nulls
harmonia<-harmonia[complete.cases(harmonia),]

#now, reshape and summarize. We want to get average counts per trap, by year- let's use plyr

library(plyr)

harmonia.year<-ddply(harmonia, "year", summarize,
                     avg=sum(ADULTS)/length(ADULTS))


colnames(harmonia.year)[1]<-"year"
colnames(harmonia.year)[2]<-"Nt"

# lets use some already built functions to do our data manipulation
source("regime_shift_detector.R")

library(reshape)
library(ggplot2)
library(gridExtra)
# for graphics, we will use the color palette GrandBudapest
# from Karthik Ram's wesanderson package
library(wesanderson)





#assign sampling year a phase, based on output of model selection

phase = c()
for (i in 1:(length(harmonia.year$year))) {
  if(harmonia.year$year[i]<2001){
    phase = c(phase, "A")
  }
  else if (harmonia.year$year[i]>2000& harmonia.year$year[i]<2006){
    phase = c(phase, "B")
  }
  else {
    phase = c(phase, "C")
  }
}
harmonia.year$phase<-phase

#phases for the lines that are to join time series points
phasea = c()
for (i in 1:(length(harmonia.year$year))) {
  if(harmonia.year$year[i]<2001.1){
    phasea = c(phasea, "A")
  }
  else if (harmonia.year$year[i]>2001& harmonia.year$year[i]<2006.1){
    phasea = c(phasea, "B")
  }
  else if (harmonia.year$year[i]>2005.9){
    phasea = c(phasea, "C")
  }
}
harmonia.year$phasea<-phasea



######################################
#
# Generate time series figure
#
######################################
pal<-wes_palette("GrandBudapest", 3)
axis.text.theme<-element_text(size=14)
axis.title.theme<-element_text(face="bold", size=16)
harmonia.year.timeseries<-ggplot(harmonia.year, aes(year, Nt, colour=phase, cex=1))+
  scale_color_manual(values = pal)+
  geom_line(data=harmonia.year, aes(x=year, y=Nt, group=phasea), size=1)+
  geom_line(size=1)+
  geom_point(size=3)+
  geom_point(colour="black", pch=21, size=3)+
  xlab("\nYear")+
  ylab("\nAverage adults per trap\n")+
  theme_bw(base_size = 10)+
  coord_equal(ratio=11)+
  geom_vline(xintercept=c(2000.5, 2005.5), colour="blue", linetype="longdash")+ 
  theme(legend.key = element_blank(),plot.margin=unit(c(15,0,0,0), "mm"))+
  theme(axis.text=axis.text.theme, axis.title=axis.title.theme, 
        legend.title=axis.title.theme, legend.text=axis.text.theme)+
  annotate("text", x=1993.8, y=0.67, label="A", size=6)


harmonia.year.timeseries





harmonia.year1<-addNt1(harmonia.year)

######################################
#
# Generate Ricker model figure
#
######################################
phase.a<-function(x){x*exp(1.31*(1- x/0.31))}
phase.b<-function(x){x*exp(2.28*(1- x/0.42))}
phase.c<-function(x){x*exp(1.55*(1- x/0.27))}




harmonia.year.ricker<-ggplot(harmonia.year1, aes(Nt, Nt1, colour=phase, label=year))+
  scale_color_manual(values = pal)+
  xlab("\nN(t)")+ylab("\nN(t+1)\n")+
  theme_bw(base_size = 16)+ 
  stat_function(fun=phase.a, colour=pal[1], size=1)+
  stat_function(fun=phase.b, colour=pal[2], size=1)+
  stat_function(fun=phase.c, colour=pal[3], size=1)+
  geom_point(size=3)+
  geom_point(colour="black", pch=21, size=3)+
  coord_equal(ratio=1)+
  xlim(-0.1,1)+ylim(-0.1,1)+
  geom_text(aes(label=year), hjust=-0.3, vjust=1, color="black", size=3)+
  theme(axis.text=axis.text.theme, axis.title=axis.title.theme, 
        legend.title=axis.title.theme, legend.text=axis.text.theme)+
  annotate("text", x=-0.09, y=0.96, label="B", size=6)

harmonia.year.ricker
harmonia.ricker.nolegend<-harmonia.year.ricker+ 
  theme(legend.position = "none", plot.margin=unit(c(0,30,10,0), "mm"))
harmonia.ricker.nolegend

pdf("figs/Figure3.pdf", height=8, width=6)
grid.arrange(arrangeGrob(harmonia.year.timeseries, harmonia.ricker.nolegend, 
                                     heights=c(1, 1)))
dev.off()