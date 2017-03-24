#clear almost everything in memory
rm(list = ls())

library(readr)

#Load Remove StopWords Function
RemStopWords<- function(text){
  stopWordsFinal <- read_lines("stopwordslists/completeListStopWords.txt")
  text = removeWords(text, c((stopWordsFinal), "melania" ,"barack", "obama", "hilary", "clinton","african","american","mexican","men","women","muslim","christian","nazi","indian","china","syria","isis","mexico","ivanka","hillary"))
  return(text)  
}

#Load All PreProcessing Tasks Function
PreProcess <- function(tweetData){
  tweetData = gsub("RT", "", as.matrix(tweetData))
  tweetData = gsub("(RT|via)((?:\\b\\W*@\\w+)+)<>", "", as.matrix(tweetData))
  tweetData = gsub("@\\w+", "", as.matrix(tweetData))
  tweetData = gsub("[[:punct:]]", "", as.matrix(tweetData))
  tweetData = gsub("[[:digit:]]", "", as.matrix(tweetData))
  tweetData = gsub("http\\w+", "", as.matrix(tweetData))
  tweetData = gsub("[ \t]{2,}", "", as.matrix(tweetData))
  tweetData = gsub("^\\s+|\\s+$", "", as.matrix(tweetData))
  tweetData = as.matrix(toLower(tweetData))
  tweetData = as.matrix(tweetData[!is.na(tweetData)])
  names(tweetData) = NULL
  return(RemStopWords(as.matrix(tweetData)))
}


### Main ###
setwd("/home/munaf/NYU_BD/individualProj/TMSA/")
tweetData <- read_csv(file="data/Tweets.csv")

# dividing tweets into 10 sets to have control over processing
s1 <- tweetData[1:100000,2]
s2 <- tweetData[100001:200000,2]
s3 <- tweetData[200001:300000,2]
s4 <- tweetData[300001:400000,2]
s5 <- tweetData[400001:500000,2]
s6 <- tweetData[500001:600000,2]
s7 <- tweetData[600001:700000,2]
s8 <- tweetData[700001:800000,2]
s9 <- tweetData[800001:900000,2]
s10 <- tweetData[900001:nrow(tweetData),2]

# Preprocess the sets (NOTE: CAN TAKE UPTO AN HOUR)
pps1 = PreProcess(s1)
pps2 = PreProcess(s2)
pps3 = PreProcess(s3)
pps4 = PreProcess(s4)
pps5 = PreProcess(s5)
pps6 = PreProcess(s6)
pps7 = PreProcess(s7)
pps8 = PreProcess(s8)
pps9 = PreProcess(s9)
pps10 = PreProcess(s10)

# save PreProcessing Results
completeResults <- rbind(pps1,pps2,pps3,pps4,pps5,pps6,pps7,pps8,pps9,pps10)
write.csv(completeResults, file = "output/PreprocessedData.csv")
