#Carcass imformation API parsing (Hanwoo)

#author: Youngjun Na
#Email: ruminoreticulum@gmail.com
#Github: https://github.com/YoungjunNa
#Last update: 11/14/2017

#library
library("XML")
library("dplyr")

#dataframe
hanwoo<-read.csv("cattle.txt",colClasses=c("character"),col.names="Cattle_No") #read the dataframe
n<-nrow(hanwoo) #number of animals 
results<-data.frame(farmerNm=rep(NA,n),farmAddr=rep(NA,n),SexNm=rep(NA,n),birthYMD=rep(NA,n),butcheryYmd=rep(NA,n),month=rep(NA,n), animalNo=rep(NA,n),gradeNm=rep(NA,n),qgrade=rep(NA,n),wgrade=rep(NA,n),weight=rep(NA,n),windex=rep(NA,n))

#API parsing
API_key<-"GET YOUR SERVICE KEY FROM data.go.kr"

for(i in 0:(n-1)){
  nb=i+1
  Cattle_No<-hanwoo[nb,]
  
  #import basic informations
  url1<-paste("http://data.ekape.or.kr/openapi-data/service/user/mtrace/breeding/cattle?cattleNo=",Cattle_No,"&ServiceKey=",API_key,sep="")
  xmlfile1<-xmlParse(url1)
  xmltop1<-xmlRoot(xmlfile1)
  get_inform<-xmlToDataFrame(getNodeSet(xmlfile1,"//item"),stringsAsFactors=FALSE)
  get_inform<-get_inform[1,]
  
  #import an issueNo
  url2<-paste("http://data.ekape.or.kr/openapi-data/service/user/grade/confirm/issueNo?animalNo=",Cattle_No,"&ServiceKey=",API_key,sep="")
  xmlfile2<-xmlParse(url2)
  xmltop2<-xmlRoot(xmlfile2)
  get_issueNo<-xmlToDataFrame(getNodeSet(xmlfile2,"//item"),stringsAsFactors=FALSE)
  get_issueNo<-get_issueNo[1,]
  
  Issue_No<-gsub(" ","",as.character(get_issueNo$issueNo)) #OR Issue_No<-stringr::str_trim(as.character(get_issueNo$issueNo))
  
  #import the carcass characteristics (by using the IssueNo)
  url3<-paste("http://data.ekape.or.kr/openapi-data/service/user/grade/confirm/cattle?issueNo=",Issue_No,"&ServiceKey=",API_key,sep="")
  xmlfile3<-xmlParse(url3)
  xmltop3<-xmlRoot(xmlfile3)
  get_hanwoo<-xmlToDataFrame(getNodeSet(xmlfile3,"//item"),stringsAsFactors=FALSE)
  get_hanwoo<-get_hanwoo[1,]
  
  if(is.null(get_inform[1,1]) == FALSE){
    results[nb,1]<-get_inform$farmNm 
    results[nb,2]<-get_inform$farmAddr
    results[nb,3]<-get_inform$sexNm 
    results[nb,4]<-get_inform$birthYmd
  }
    
  if(is.null(get_issueNo[1,1]) == FALSE){
    results[nb,7]<-get_issueNo$animalNo 
  }
  
  if(is.null(get_hanwoo[1,1]) == FALSE){
    results[nb,5]<-get_inform$butcheryYmd
    results[nb,6]<-(as.Date(get_inform$butcheryYmd)-as.Date(get_inform$birthYmd))/(365/12)
    
    results[nb,8]<-get_hanwoo$gradeNm 
    results[nb,9]<-get_hanwoo$qgrade 
    
  }
  
  if(is.null(get_hanwoo[1,1]) == FALSE){
    results[nb,10]<-get_hanwoo$wgrade
    results[nb,11]<-as.numeric(get_hanwoo$weight)
    results[nb,12]<-as.numeric(get_hanwoo$windex)
  }
} 


get_hanwoo$qgrade != "D" 

#%>% try(silent=TRUE)
#%>% system.time()

results <- filter(results, windex != "NA") #delete NA 
results_steer<-filter(results, SexNm == "거세") #filtering the steers
write.csv(results, "results.txt", row.names=FALSE) #write csv
