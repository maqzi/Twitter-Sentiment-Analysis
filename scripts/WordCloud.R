#clear almost everything in memory
rm(list = ls())

library(readr)
library(wordcloud)
library(RColorBrewer)
library(tm)
library(quanteda)

#Load Remove StopWords Function (only common english words)
RemStopWords<- function(text){
  stopWordsFinal <- read_lines("stopwordslists/completeListStopWords.txt")
  text = removeWords(text, c((stopWordsFinal)))
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


# read data
setwd("/home/munaf/NYU_BD/individualProj/TMSA/")
Results <- read_csv(file="output/PolarityAnalysis.csv")
colnames(Results)[1] <- "Tweet_Num"
tweets <- read_csv(file="data/Tweets.csv")
tweets <- tweets[,2]

#preprocess tweets (NOTE: CAN TAKE UPTO AN HOUR)
some_txt <- PreProcess(tweets)

# create dataframe
polarity = Results[,5]
polarity_df = data.frame(text=some_txt, polarity=polarity, stringsAsFactors=FALSE)
colnames(polarity_df)[1] <- "words"
colnames(polarity_df)[2] <- "polarity"

# separating text by emotion
emos = levels(factor(polarity_df$polarity))
nemo = length(emos)
emo.docs = rep("", nemo)
for (i in 1:nemo)
{
  tmp = some_txt[polarity == emos[i]]
  emo.docs[i] = paste(tmp, collapse=" ")
}

# remove stopwords
emo.docs = removeWords(emo.docs, stopwords("english"))
# create corpus
corpus = Corpus(VectorSource(emo.docs))
tdm = TermDocumentMatrix(corpus)
tdm = as.matrix(tdm)
colnames(tdm) = emos

# comparison word cloud
x11()
comparison.cloud(tdm,  min.freq=2, colors = brewer.pal(nemo, "Dark2"),
                 scale = c(5,1), random.order = FALSE, title.size = 1.5)
dev.copy2pdf(file = "output/wordcloud.pdf")

