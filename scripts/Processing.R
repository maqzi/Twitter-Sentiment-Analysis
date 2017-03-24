#clear almost everything in memory
rm(list = ls())

library(readr)

#Load All Processing Tasks Function
Process <- function(textColumns,num) {
  
  verbose = FALSE
  pweak = 1.0
  pstrong = 0.5
  algorithm = "bayes"
  prior = 1.0
  
  control <- list(language="english",tolower=TRUE,removeNumbers=TRUE,removePunctuation=TRUE,stripWhitespace=TRUE,minWordLength=TRUE,stopwords=TRUE,minDocFreq=1)
  trainingColumn <- apply(as.matrix(textColumns),1,paste,collapse=" ")
  trainingColumn <- sapply(as.vector(trainingColumn,mode="character"),iconv,to="UTF8",sub="byte")
  corpus <- Corpus(VectorSource(trainingColumn),readerControl=list(language="english"))
  matrix <- DocumentTermMatrix(corpus,control=control)
  
  #now<-format(Sys.time(), "%b%d%H%M%S")
  #outputfile <- paste("output/DocumentTermMatrix-",now,".txt", sep="")
  #adtm.df<-as.data.frame(as.matrix(matrix))
  #write.table(as.data.frame(as.matrix(matrix)),file = outputfile)
  
  lexicon <- read.csv(file="classifierlists/Subjectivity.csv",header = FALSE)
  counts <- list(positive=length(which(lexicon[,3]=="positive")),negative=length(which(lexicon[,3]=="negative")),total=nrow(lexicon))
  documents <- c()
  
  for (i in 1:nrow(matrix)) {
    if (verbose) print(paste("DOCUMENT",i))
    scores <- list(positive=0,negative=0)
    doc <- matrix[i,]
    words <- findFreqTerms(doc,lowfreq=1)
    
    for (word in words) {
      index <- pmatch(word,lexicon[,1],nomatch=0)
      if (index > 0) {
        entry <- lexicon[index,]
        
        polarity <- as.character(entry[[2]])
        category <- as.character(entry[[3]])
        count <- counts[[category]]
        
        score <- pweak
        if (polarity == "strongsubj") score <- pstrong
        if (algorithm=="bayes") score <- abs(log(score*prior/count))
        
        if (verbose) {
          print(paste("WORD:",word,"CAT:",category,"POL:",polarity,"SCORE:",score))
        }
        
        scores[[category]] <- scores[[category]]+score
      }		
    }
    
    if (algorithm=="bayes") {
      for (key in names(scores)) {
        count <- counts[[key]]
        total <- counts[["total"]]
        score <- abs(log(count/total))
        scores[[key]] <- scores[[key]]+score
      }
    } else {
      for (key in names(scores)) {
        scores[[key]] <- scores[[key]]+0.000001
      }
    }
    
    best_fit <- names(scores)[which.max(unlist(scores))]
    ratio <- as.integer(abs(scores$positive/scores$negative))
    if (ratio==1) best_fit <- "neutral"
    documents <- rbind(documents,c(scores$positive,scores$negative,abs(scores$positive/scores$negative),best_fit))
    if (verbose) {
      print(paste("POS:",scores$positive,"NEG:",scores$negative,"RATIO:",abs(scores$positive/scores$negative)))
      cat("\n")
    }
    if(i %% 1000L == 1){
      print(paste("DOC:",i,"POS:",scores$positive,"NEG:",scores$negative,"RATIO:",abs(scores$positive/scores$negative)))
      cat("\n")
    }
  }
  gc()
  colnames(documents) <- c("POS","NEG","POS/NEG","BEST_FIT")
  return( documents)
}

### Main ###
setwd("/home/munaf/NYU_BD/individualProj/TMSA/")
PreProcessedData <- read_csv(file="output/PreprocessedData.csv")


# dividing tweets into 10 sets to have control over processing
s1 <- PreProcessedData[1:100000,2]
s2 <- PreProcessedData[100001:200000,2]
s3 <- PreProcessedData[200001:300000,2]
s4 <- PreProcessedData[300001:400000,2]
s5 <- PreProcessedData[400001:500000,2]
s6 <- PreProcessedData[500001:600000,2]
s7 <- PreProcessedData[600001:700000,2]
s8 <- PreProcessedData[700001:800000,2]
s9 <- PreProcessedData[800001:900000,2]
s10 <- PreProcessedData[900001:nrow(PreProcessedData),2]


# Process Polarity of tests (NOTE: CAN TAKE UPTO 10 HOURS)
ps1 = Process(s1)
ps2 = Process(s2)
ps3 = Process(s3)
ps4 = Process(s4)
ps5 = Process(s5)
ps6 = Process(s6)
ps7 = Process(s7)
ps8 = Process(s8)
ps9 = Process(s9)
ps10 = Process(s10)

# write polarity results
completeResults <- rbind(ps1,ps2,ps3,ps4,ps5,ps6,ps7,ps8,ps9,ps10)
write.csv(completeResults, file = "output/PolarityAnalysis.csv")

