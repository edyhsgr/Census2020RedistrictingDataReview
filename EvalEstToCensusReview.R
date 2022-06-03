##########
#REVIEW OF US CENSUS BUREAU'S 2010 AND 2020 EVALUATION ESTIMATES - COUNTY TOTAL POPULATION ERRORS
#
#2020 CENSUS AND 2020 EVALUATION ESTIMATES DATA DOWNLOADED IN AUGUST 2021 FROM US CENSUS BUREAU
#2010 CENSUS DATA DOWNLOADED IN MAY 2022 FROM IPUMS NHGIS, UNIVERSITY OF MINNESOTA; 2010 EVALUATION ESTIMATES DATA DOWNLOADED IN MAY 2022 FROM US CENSUS BUREAU
#
#EDDIE HUNSINGER, MAY 2022 (UPDATED JUNE 2022)
#https://edyhsgr.github.io/
#
#THERE IS NO WARRANTY FOR THIS CODE
#THIS CODE HAS NOT BEEN TESTED AT ALL-- PLEASE LET ME KNOW IF YOU FIND ANY PROBLEMS (edyhsgr@gmail.com)
##########

library(shiny)
library(gplots)

CountyData_2020<-read.table(file="https://raw.githubusercontent.com/edyhsgr/Census2020RedistrictingDataReview/main/Tabulation_Counties_2020.csv",header=TRUE,sep=",")
CountyData_2010<-read.table(file="https://raw.githubusercontent.com/edyhsgr/Census2020RedistrictingDataReview/main/Tabulation_Counties_2010.csv",header=TRUE,sep=",")

statecode<-c(1,2,4,5,6,8,9,10,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,44,45,46,47,48,49,50,51,53,54,55,56)
statename<-c("Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","Florida","Georgia",
		"Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland",
		"Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire",
		"New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina",
 		"South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming")

Names_State<-data.frame(statecode)
Names_State$NAME_STATE<-statename

CountyData_2020<-merge(CountyData_2020,Names_State,by.x="STATE",by.y="statecode",all.x=TRUE)
CountyData_2020$NAME<-sub(" city"," City",CountyData_2020$NAME)
CountyData_2020$NAME_FULL<-paste(CountyData_2020$NAME,CountyData_2020$NAME_STATE)

colnames(CountyData_2010)[1:11]<-c("StateCode","CountyCode","GISJoinMatchCode","DataFileYear","RegionCode","DivisionCode","StateName","CountyName","CENSUS2010","Comment","FullName")

Names<-CountyData_2020$NAME_FULL[CountyData_2020$NAME_FULL!="Chugach Census Area Alaska" & ##NOTE: NEED TO REPAIR THIS SO SOME INFO IS AVAILABLE FOR THESE
						CountyData_2020$NAME_FULL!="Copper River Census Area Alaska" &
						CountyData_2020$NAME_FULL!="Kusilvak Census Area Alaska" &
						CountyData_2020$NAME_FULL!="Petersburg Borough Alaska" &						
						CountyData_2020$NAME_FULL!="Prince of Wales-Hyder Census Area Alaska" &
				                CountyData_2020$NAME_FULL!="Oglala Lakota County South Dakota"]

ui<-fluidPage(

tags$h3("Review of US Census Bureau's 2010 and 2020 Evaluation Estimates, County Total Population Errors"),
  
hr(),

sidebarLayout(
sidebarPanel(

selectizeInput(inputId = "County", label = "County (or equivalent)", 
choices = Names,
options = list(placeholder = "Type in a county to see graphs", multiple = TRUE, maxOptions = 5000, onInitialize = I('function() { this.setValue(""); }'))
),

radioButtons("radio","",c("Use Mean Absolute Percent Error (MAPE)" = 1, "Use Median Absolute Percent Error (MedAPE)" = 2),selected = 1),

sliderInput("ITER","Sample size for error bound estimation",min=500,max=5000,value=1000,step=500),

hr(),

p("2020 Census Redistricting data downloaded in August 2021 from ",
tags$a(href="https://www.census.gov/data/datasets/2020/dec/2020-census-redistricting-summary-file-dataset.html", 
	"the U.S. Census Bureau."),
"2020 Evaluation Estimates downloaded in August 2021 from ",
tags$a(href="https://www.census.gov/programs-surveys/popest/technical-documentation/research/evaluation-estimates.2020.html", 
	"the U.S. Census Bureau."),
"2010 Census Redistricting data downloaded in May 2022 from ",
tags$a(href="https://www.nhgis.org/", 
	"IPUMS NHGIS, University of Minnesota."),
"2010 Evaluation Estimates downloaded in May 2022 from ",
tags$a(href="https://www.census.gov/programs-surveys/popest/technical-documentation/research/evaluation-estimates.2010.html", 
	"the U.S. Census Bureau."),

p(tags$a(href="https://www.census.gov/library/working-papers/2013/demo/POP-twps0100.html", 
	"U.S. Census Bureau report from 2013"),
	"with in-depth analysis of 2010 Evaluation Estimates."),

hr(),

p("This interface was made with ",
tags$a(href="https://shiny.rstudio.com/", 
	"Shiny for R."),
tags$a(href="https://github.com/edyhsgr/Census2020RedistrictingDataReview", 
	"Related GitHub repository."),
tags$a(href="https://edyhsgr.github.io/", 
	"Eddie Hunsinger, "),
"May 2022 (updated in June 2022.")),

width=3
),

mainPanel(
	
	plotOutput("plots"),width=3)
)
)

CountyData<-CountyData_2020

server<-function(input, output) {	
	output$plots<-renderPlot({
par(mfrow=c(1,2)) #,mai=c(0.5,0.5,0.5,0.5))

##GRAPHS

iter<-input$ITER
bootstrapper<-function(iter,data,low,high) { 
	bootstrapMedian<-bootstrapMean<-array(,iter)
	for(i in 1:length(bootstrapMean)) {
		bootstrapMean[i]<-mean(sample(data,length(data),replace=TRUE))}
	for(i in 1:length(bootstrapMedian)) {
		bootstrapMedian[i]<-median(sample(data,length(data),replace=TRUE))}
	return(c(bootstrapLowMean=quantile(bootstrapMean,low),bootstrapHighMean=quantile(bootstrapMean,high),
		bootstrapLowMedian=quantile(bootstrapMedian,low),bootstrapHighMedian=quantile(bootstrapMedian,high)))}

if(input$County=="") {
plot.new()
legend("topleft",legend=c("Select a county with the panel to the left"),cex=1.5,bty="n")
}

if(input$County!="") {
if(input$radio==1) {
	#####2010 Mean Errors	##NOTE, SHOULD ADD SOMETHING MORE (THAN TEXT VALUE) TO IDENTIFY BARS THAT EXPAND OUTSIDE OF PLOT AREA
	CountySelect_2010<-subset(CountyData_2010,CountyData_2010$FullName==input$County) 
	
	StateSelect_2010<-aggregate(CountyData_2010$AbsPctError,by=list(CountyData_2010$StateName),FUN=mean)
	names(StateSelect_2010)<-c("StateName","MAPE_Counties")
	County_StateSelect_2010<-merge(CountySelect_2010,StateSelect_2010,by="StateName")
	
	MAPE_Counties_National_2010<-mean(CountyData_2010$AbsPctError)

	bootstrapState_2010<-bootstrapper(iter,CountyData_2010$AbsPctError[CountyData_2010$StateCode==County_StateSelect_2010$StateCode],.05,.95)
	bootstrapNatl_2010<-bootstrapper(iter,CountyData_2010$AbsPctError,.05,.95)
	
	barplot2(c(CountySelect_2010$AbsPctError,County_StateSelect_2010$MAPE_Counties,MAPE_Counties_National_2010),
		plot.ci=TRUE,ci.l=c(NA,bootstrapState_2010[1],bootstrapNatl_2010[1]),ci.u=c(NA,bootstrapState_2010[2],bootstrapNatl_2010[2]),		
		col=c("gold","limegreen","powderblue"),border=NA,ylim=c(0,10),las=1,
		names.arg=c(CountySelect_2010$CountyName,paste(c(CountySelect_2010$StateName," Counties"),collapse=""),
		"Nationwide Counties"),cex.names=1.15,cex.axis=1.25,main="2010 Evaluation Estimates Total Population Error",cex.main=1.5)
	mtext(side=1,line=-CountySelect_2010$AbsPctError-1.25,adj=.13,text=paste(c("APE: ",round(CountySelect_2010$AbsPctError,2)),collapse=""),font=.5,cex=1)
	mtext(side=1,line=-County_StateSelect_2010$MAPE_Counties-1.25,adj=.5,text=paste(c("MAPE: ",round(County_StateSelect_2010$MAPE_Counties,2)),collapse=""),cex=1)
	mtext(side=1,line=-MAPE_Counties_National_2010-1.25,adj=.89,text=paste(c("MAPE: ",round(MAPE_Counties_National_2010,2)),collapse=""),cex=1)

	mtext(side=1,line=4,adj=0,text=paste(c("'Counties' includes all county-equivalent areas. APE is absolute percent error and MAPE is mean absolute percent error. 
		The error bars cover 90 percent of the uncertainty distribution for the respective measurement, estimated by random sampling with replacement.")),cex=1.15)
	#####

	#####2020 Mean Errors
	CountySelect_2020<-subset(CountyData_2020,CountyData_2020$NAME_FULL==input$County) 
	
	StateSelect_2020<-aggregate(CountyData_2020$AbsPctError,by=list(CountyData_2020$STATE),FUN=mean)
	names(StateSelect_2020)<-c("STATE","MAPE_Counties")
	County_StateSelect_2020<-merge(CountySelect_2020,StateSelect_2020,by="STATE")
	
	MAPE_Counties_National_2020<-mean(CountyData_2020$AbsPctError)

	bootstrapState_2020<-bootstrapper(iter,CountyData_2020$AbsPctError[CountyData_2020$STATE==County_StateSelect_2020$STATE],.05,.95)
	bootstrapNatl_2020<-bootstrapper(iter,CountyData_2020$AbsPctError,.05,.95)
	
	barplot2(c(CountySelect_2020$AbsPctError,County_StateSelect_2020$MAPE_Counties,MAPE_Counties_National_2020),
		plot.ci=TRUE,ci.l=c(NA,bootstrapState_2020[1],bootstrapNatl_2020[1]),ci.u=c(NA,bootstrapState_2020[2],bootstrapNatl_2020[2]),
		col=c("gold","limegreen","powderblue"),ci.color=c(NA,1,1),border=NA,ylim=c(0,10),las=1,
		names.arg=c(CountySelect_2020$NAME,paste(c(CountySelect_2020$NAME_STATE," Counties"),collapse=""),
		"Nationwide Counties"),cex.names=1.15,cex.axis=1.25,main="2020 Evaluation Estimates Total Population Error",cex.main=1.5)
	mtext(side=1,line=-CountySelect_2020$AbsPctError-1.25,adj=.13,text=paste(c("APE: ",round(CountySelect_2020$AbsPctError,2)),collapse=""),font=.5,cex=1)
	mtext(side=1,line=-County_StateSelect_2020$MAPE_Counties-1.25,adj=.5,text=paste(c("MAPE: ",round(County_StateSelect_2020$MAPE_Counties,2)),collapse=""),cex=1)
	mtext(side=1,line=-MAPE_Counties_National_2020-1.25,adj=.87,text=paste(c("MAPE: ",round(MAPE_Counties_National_2020,2)),collapse=""),cex=1)
	#####
	}

if(input$radio==2) {
	#####2010 Median Errors
	CountySelect_2010<-subset(CountyData_2010,CountyData_2010$FullName==input$County) 
	
	StateSelect_2010<-aggregate(CountyData_2010$AbsPctError,by=list(CountyData_2010$StateName),FUN=median)
	names(StateSelect_2010)<-c("StateName","MedAPE_Counties")
	County_StateSelect_2010<-merge(CountySelect_2010,StateSelect_2010,by="StateName")
	
	MedAPE_Counties_National_2010<-median(CountyData_2010$AbsPctError)
	
	bootstrapState_2010<-bootstrapper(iter,CountyData_2010$AbsPctError[CountyData_2010$StateCode==County_StateSelect_2010$StateCode],.05,.95)
	bootstrapNatl_2010<-bootstrapper(iter,CountyData_2010$AbsPctError,.05,.95)
	
	barplot2(c(CountySelect_2010$AbsPctError,County_StateSelect_2010$MedAPE_Counties,MedAPE_Counties_National_2010),
		plot.ci=TRUE,ci.l=c(NA,bootstrapState_2010[3],bootstrapNatl_2010[3]),ci.u=c(NA,bootstrapState_2010[4],bootstrapNatl_2010[4]),		
		col=c("gold","limegreen","powderblue"),border=NA,ylim=c(0,10),las=1,
		names.arg=c(CountySelect_2010$CountyName,paste(c(CountySelect_2010$StateName," Counties"),collapse=""),
		"Nationwide Counties"),cex.names=1.15,cex.axis=1.25,main="2010 Evaluation Estimates Total Population Error",cex.main=1.5)
	mtext(side=1,line=-CountySelect_2010$AbsPctError-1.25,adj=.13,text=paste(c("APE: ",round(CountySelect_2010$AbsPctError,2)),collapse=""),font=.5,cex=1)
	mtext(side=1,line=-County_StateSelect_2010$MedAPE_Counties-1.25,adj=.5,text=paste(c("MedAPE: ",round(County_StateSelect_2010$MedAPE_Counties,2)),collapse=""),cex=1)
	mtext(side=1,line=-MedAPE_Counties_National_2010-1.25,adj=.89,text=paste(c("MedAPE: ",round(MedAPE_Counties_National_2010,2)),collapse=""),cex=1)

	mtext(side=1,line=4,adj=0,text=paste(c("'Counties' includes all county-equivalent areas. APE is absolute percent error and MedAPE is median absolute percent error. 
		The error bars cover 90 percent of the uncertainty distribution for the respective measurement, estimated by random sampling with replacement.")),cex=1.15)
	#####

	#####2020 Median Errors
	CountySelect_2020<-subset(CountyData_2020,CountyData_2020$NAME_FULL==input$County) 
	
	StateSelect_2020<-aggregate(CountyData_2020$AbsPctError,by=list(CountyData_2020$STATE),FUN=median)
	names(StateSelect_2020)<-c("STATE","MedAPE_Counties")
	County_StateSelect_2020<-merge(CountySelect_2020,StateSelect_2020,by="STATE")
	
	MedAPE_Counties_National_2020<-median(CountyData_2020$AbsPctError)
	
	bootstrapState_2020<-bootstrapper(iter,CountyData_2020$AbsPctError[CountyData_2020$STATE==County_StateSelect_2020$STATE],.05,.95)
	bootstrapNatl_2020<-bootstrapper(iter,CountyData_2020$AbsPctError,.05,.95)
	
	barplot2(c(CountySelect_2020$AbsPctError,County_StateSelect_2020$MedAPE_Counties,MedAPE_Counties_National_2020),
		plot.ci=TRUE,ci.l=c(NA,bootstrapState_2020[3],bootstrapNatl_2020[3]),ci.u=c(NA,bootstrapState_2020[4],bootstrapNatl_2020[4]),
		col=c("gold","limegreen","powderblue"),ci.color=c(NA,1,1),border=NA,ylim=c(0,10),las=1,
		names.arg=c(CountySelect_2020$NAME,paste(c(CountySelect_2020$NAME_STATE," Counties"),collapse=""),
		"Nationwide Counties"),cex.names=1.15,cex.axis=1.25,main="2020 Evaluation Estimates Total Population Error",cex.main=1.5)
	mtext(side=1,line=-CountySelect_2020$AbsPctError-1.5,adj=.13,text=paste(c("APE: ",round(CountySelect_2020$AbsPctError,2)),collapse=""),font=.5,cex=1)
	mtext(side=1,line=-County_StateSelect_2020$MedAPE_Counties-1.5,adj=.5,text=paste(c("MedAPE: ",round(County_StateSelect_2020$MedAPE_Counties,2)),collapse=""),cex=1)
	mtext(side=1,line=-MedAPE_Counties_National_2020-1.5,adj=.87,text=paste(c("MedAPE: ",round(MedAPE_Counties_National_2020,2)),collapse=""),cex=1)
	#####
	}

}

},height=600,width=1200)
		
}

shinyApp(ui = ui, server = server)

