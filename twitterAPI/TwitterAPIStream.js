var TwitterStream = require('twitter-stream-api'),
    fs = require('fs');

var tweetCount=0;
var collection;
var mongo = require('mongodb');
var MongoClient = require('mongodb').MongoClient;
MongoClient.connect("mongodb://localhost:27017/Individ_TMSA", function(err, db) {
  if(!err) {
    console.log("We are connected");
  }

db.createCollection('tweetsStream', function(err, collection) {});
collection = db.collection('tweetsStream');
});


var keys = {
    consumer_key : "fNPNFkFYJEEA4dKZJ0r211Qux",
    consumer_secret : "fkDOMGswOswarigojKPpu0LmXMfXa7CbZVe7o7WhAlBTIqT4Hi",
    token : "1636049887-nKGz1uePpy33gIngFVBAkW5Zw9t9LyXgwXX9vJ2",
    token_secret : "Cc4UfHsISy8W3I2acTNBNND1XoM0oiuz6hFS0wKcLu4jM"
};

var Twitter = new TwitterStream(keys, false);

Twitter.on('data', function (data) {

try {
        if (tweetCount < 1000000){
            var parsedTweet = JSON.parse(data.toString());

            if (parsedTweet.id && parsedTweet.id_str) {
                parsedTweet._id = new mongo.Long.fromString(parsedTweet.id_str, 10);

                collection.insert(parsedTweet, function (err, doc) {
                    console.log("Error writing document to database. Most likely a duplicate.");
                });
		tweetCount++;
		console.log('inserted: ',tweetCount);
                }
        } else { 
            process.exit(0); 
        }
    } catch (e) {
        console.log("Exception thrown: " + e.message);
    }
});

Twitter.stream('statuses/filter', {
    track: 'trump'
});

Twitter.on('connection success', function (uri) {
    console.log('connection success', uri);
});

Twitter.on('connection aborted', function () {
    console.log('connection aborted');
});

Twitter.on('connection error unknown', function (error) {
    console.log('connection error unknown', error);
    Twitter.close();
});

Twitter.on('data error', function (error) {
    console.log('data error', error);
});

Twitter.on('connection error http', function (httpStatusCode) {
    console.log('connection error http', httpStatusCode);
});

Twitter.on('connection error stall', function () {
    console.log('connection error stall');
});

Twitter.on('data keep-alive', function () {
    console.log('data keep-alive');
});

Twitter.on('connection rate limit', function (httpStatusCode) {
    console.log('connection rate limit', httpStatusCode);
});
