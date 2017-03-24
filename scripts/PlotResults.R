#clear almost everything in memory
rm(list = ls())

library(ggplot2)
library(readr)

# read data
setwd("/home/munaf/NYU_BD/individualProj/TMSA/")
Results <- read_csv(file="output/PolarityAnalysis.csv")
colnames(Results)[1] <- "Tweet_Num"


# create data frame
polarity = Results[,5]
polarity_df = data.frame(polarity=polarity, stringsAsFactors=FALSE)
colnames(polarity_df)[1] <- "polarity"

# sort data frame
polarity_df = within(polarity_df,
                 polarity <- factor(polarity, levels=names(sort(table(polarity), decreasing=TRUE))))

# plotting
x11()
ggplot(polarity_df, aes(x=polarity)) +
  geom_bar(aes(y=..count.., fill=polarity)) +
  scale_fill_brewer(palette="RdGy") +
  labs(x="polarity categories", y="number of tweets") +
  labs(title = "Polarity of Twitter on TRUMP")
dev.copy2pdf(file = "output/polarity.pdf")
