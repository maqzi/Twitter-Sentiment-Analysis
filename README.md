# Twitter-Sentiment-Analysis
Polarity Analysis in R after getting tweets from the Twitter Streaming API (JS)

## Disclaimer
I do not have any affiliation with any political party. This study was conducted purely for educational purposes.

## Introduction
2016 has been an eventful year, especially considering the POTUS electoral race. The media has been presenting it’s side of the story while we’ve been hearing numerous times that President Elect Donald Trump is unhappy with the way he has been treated by media. The biggest surprise to everyone came when despite all odds (according to the media), Donald Trump won the elections showing he actually had a lot of support throughout the US. Since winning, PEOTUS has made a number of controversial decisions which have been heavily criticized/appreciated so when I heard him going back on his word of not pursuing Hilary Clinton Email Charges on the 22nd of November 2016, I wanted to see how the world reacted.

## Approach
Twitter has two major APIs. A Rest API and a Stream API. The rest API can be used effectively for mining out tweets and is easily integrable into R, however with one drawback. To collect data, twitter has a 15 requests per 15 minutes limit [1], which in no way can be used to accumulate a million records without having multiple nodes with different keys making requests simultaneously. Therefore I decided to start writing a NodeJS script which would connect to twitter’s streaming API and help me collect data in real time. The responses needed to be unique as well because identical tweets would just be added noise in my analysis and take up unnecessary storage space. 

Once data was downloaded, I decided to filter out the fields of importance from it using map reduce. A Map Reduce job usually splits the input data-set into independent chunks which are processed by the map tasks in a completely parallel manner. The framework sorts the outputs of the maps, which are then input to the reduce tasks. Typically both the input and the output of the job are stored in a file-system. The framework takes care of scheduling tasks, monitoring them and re-executes the failed tasks [2]. 

Map Reduce can be applied to a number of different design patterns. Be it Filtering or Summarizations, Joins or Data Organizations all can be made simple by using such patterns. Following the book Map Reduce Patterns by Donald Miner [3] I was able to write a map reduce filtering script in both Mongo and Hadoop using Pig! Although I ended up using only the Mongo one because of my data was in Mongo aswell, both scripts are usable for the task except the data will need to be imported to HDFS for Pig. I have provided both scripts in the TMSA>scripts folder. Once map reduce was complete, using mongo scripts the data was exported into a CSV and ready for R analysis. 

Polarity analysis is classifying the polarity of a given text at the document, sentence, or feature/aspect level—whether the expressed opinion in a document, a sentence or an entity feature/aspect is positive, negative, or neutral.[4] For any such sentiment analysis, text needs to be converted in to numbers which a machine can understand. Thus lower casing, removing stop words, tokenizing all are processes which need to be done then. For the stop words, because this was for twitter feeds, which contains jargon and slangs, I created a stop words corpus of common words from the English language, Snowball corpus, terrier corpus and the minimal corpus. One can now gauge the polarity of text based on positive/negative dictionaries and create relevant plots. I used Bayesian classifier to learn about sentiments from a learner list and then applied the classifier to the tweets and analyzed the results.

## Instructions
Instructions to run the complete program:

1. Get Data from Twitter API, save it in a MongoDB using TwitterAPIStream.js. (Note: can take upto 9 hours)  
	a. Run MongoServer  
	b. Make sure you have NodeJS installed. get it on ubuntu using: sudo apt-get install nodejs  
	c. Make sure you have node package manager installed. get it using: sudo apt-get install npm  
	d. Navigate to folder TMSA>twitterAPI and run javascript in terminal using: node TwitterAPIStream.js  
	e. Program will run indefinitely searching for tweets around the world with the word: 'trump'  
	f. It will run till a million tweets have been downloaded and saved into a mongo collection called 'tweetsStream' in database 'Individ_TMSA'  
  
2. Filter Tweets using MapReduce in MongoDB.  
	a. Start mongo shell in terminal using: mongo  
	b. Use the Database called Individ_TMSA using: use Individ_TMSA  
	c. Type in the Map Reduce Script present in TMSA>MapReduceImplementation>Mongo folder  
	d. A new collection called 'MRTweetsText' will be created  
	e. check using: show collections  
	f. Quit mongo shell using: exit  
  
3. Type in the scripts>MongoExport script (# Export Map Reduce Filtered Tweets Only) in the bash terminal changing the output path as per your system. Set the output path for exported csv to be the TMSA>data folder.  
  
4. Loading & Preprocessing. (Note: can take upto an hour)  
	a. Run R Studio and open the script TMSA>load>Load&Preprocess.R  
	b. Change the working directory path in line 31  
	c. Execute script to create, in the TMSA>output folder, the file: 'Preprocessed.csv'  
  
5. Processing Data. (Note: can take upto 10 hours)  
	a. Run R Studio and open the script TMSA>scripts>Processing.R  
	b. Set the working directory path in line 89  
	c. Execute the script to create in the TMSA>output folder, the file: PolarityAnalysis.csv  
  
6. Plotting Polarity Results.  
	a. Run R Studio and open the script TMSA>scripts>PlotResults.R  
	b. Set the working directory path in line 8  
	c. Execute the script to create the ggplot in the TMSA>output folder named: polarity.pdf  
  
7. Creating WordCloud.  
	a. Run R Studio and open the script TMSA>scripts>WordCloud.R  
	b. Set the working directory path in line 35  
	c. Execute the script to create the wordcloud in the TMSA>output folder named: wordcloud.pdf  
  
  
* I have NOT included my dataset from Step 1 through 3 in the TMSA>data folder. It is available on request.
* I have  NOT included the complete dataset recorded using the Twitter Streaming API in the TMSA>data folder. It is available on request. 
* I have NOT included the compiled sentiment polarity training list "Sentiment_Analysis_POSNEG_Dataset.csv" in TMSA>classifierlists. It is available on request.
* The script to export complete data set can also be found inside the scripts>MongoExport text file.  
* Incase of a permissions error on the twitter streaming api, create a twitter app and use your own keys.  
* I have removed my PreprocessedData.csv and PolarityAnalysis.csv from TMSA>output folder. 
* TMSA = Twitter Mining and Sentiment Analysis. I have used an abbreviation everywhere. Assume root directory name if you clone/fork.
  
## Addendum:
* Make sure the path is set properly up till the folder TMSA for e.g. /home/munaf/NYU_BD/individualProj/TMSA/  
* The Twitter Streaming API is configured to save data in a mongo db running on localhost on port 27017. For different settings, configure it accordingly  

## References
[1] Twitter API Rate Limits. https://dev.twitter.com/rest/public/rate-limiting  
[2] Hadoop. Map Reduce Tutorial. https://hadoop.apache.org/docs/r1.2.1/mapred_tutorial.html.  
[3] Miner. Donald. Map Reduce Patterns http://barbie.uta.edu/jli/Resources/MapReduce&Hadoop/MapReduce%20De  
[4] Sentiment Analysis. Wikipedia. https://en.wikipedia.org/wiki/Sentiment_analysis.  
