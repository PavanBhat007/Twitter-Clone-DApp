// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

contract Twitter {

    // creating a mapping for storing user's tweets
    mapping(address => Tweet[]) public tweets; // { addr : [Tweet, Tweet, ...] }

    // defining a structure for Tweets
    struct Tweet {
        uint256 id;          // id to identify / index the tweet
        address author;      // who sends the tweet
        string body;         // tweet content
        uint256 timestamp;   // when was tweet was tweeted
        uint256 likes;       // how many likes on the tweet
    }

    uint16 public TWEET_MAX_LEN = 500;

    // safeguarding against un-authorized users to modify the TWEET_MAX_LEN
    address public owner; // creating a variable to define the owner
    // constrcutor is implicitly called (similar to an __init__ function)
    constructor() {
        owner = msg.sender; // assigning the sender to the owner
    }

    // defining who can "modify"
    // it is a user-defined access specifier (like public, private, etc)
    modifier onlyOwner() {
        // check if the current sender is the defined owner or not
        require(msg.sender == owner, "You don't have rights to perform that operation");
        _; // this tells the compiler to stop or close the modifier
    }
    
    // defining events that can be triggered via the code when some action happens
    event TweetCreated(uint256 tweetId, address author, string content, uint256 timestamp);
    event TweetLiked(address liker, address author, uint256 tweetId, uint256 likeCount);
    event TweetUnliked(address unLiker, address author, uint256 tweetId, uint256 likeCount);


    // function to change the TWEET_MAX_LEN which has an access modfier of onlyOwner
    // only for users where the onlyOwner passes the require(), the function will execute
    function changeTweetLength(uint16 newTweetLength) public onlyOwner {
        TWEET_MAX_LEN = newTweetLength;
    }

    function createTweet(string memory _tweet) public {
        // checking if tweet exceeds max character limit
        // require(condition, <false_case_output>) is hoe Solidity implements conditionals
        require(bytes(_tweet).length <= TWEET_MAX_LEN, "Tweet is too long!!");

        // creating a Tweet if above require is passed
        // since it is a "struct" it will be stored in memory
        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,  // get the index of the tweet
            author: msg.sender,             // author is the one who sent the request
            body: _tweet,                   // _tweet is the actual tweet itself (string)
            timestamp: block.timestamp,     // block.timestamp provides the timestamp by default (in-built)
            likes: 0                        // initially tweet has 0 likes
        });

        // using msg.sender (key) to get the particular sender's tweets
        // it is an array of Tweets so we will push the tweet into the array
        tweets[msg.sender].push(newTweet);

        // when the tweet is created we will trigger the TweetCreated event
        emit TweetCreated(newTweet.id, newTweet.author, newTweet.body, newTweet.timestamp);
    }

    // getter function to get the tweets of a user using _owner to get all tweets
    // and _index to get the particular tweet using the array-indexing
    // we are going to return an instance of the Tweet struct
    function getTweet(address _owner, uint _index) public view returns (Tweet memory) {
        return tweets[_owner][_index];
    }

    // getter function to get all the tweets of a user using the _owner to index the mapping
    // here the array of Tweet instances will be returned
    function getAllTweets(address _owner) public view returns (Tweet[] memory) {
        return tweets[_owner];
    }

    // function that updates the like field of a specific tweet of a particular user
    function likeTweet(address _user, uint _index) external {
        // check if provided index is in range
        require(tweets[_user].length >= _index, "Provided index is out of range");

        // check if the tweet exists
        require(tweets[_user][_index].id == _index, "Tweet not found");

        // index the specific tweet of the user using the _user and _index
        // tweets[_user][_index] give the Tweet instance whose the like field is to be updated
        tweets[_user][_index].likes++;

        // when a tweet is liked by a user we will trigger the TweetLiked event
        emit TweetLiked(msg.sender, _user, _index, tweets[_user][_index].likes);
    }

    // function that updates the like field of a specific tweet of a particular user
    function unLikeTweet(address _user, uint _index) external {
        // check if the tweet exists
        require(tweets[_user][_index].id == _index, "Tweet not found");

        // check if the tweet has any likes to be unliked
        // safeguarding against negative like numbers
        require(tweets[_user][_index].likes > 0, "Tweet has 0 likes already");

        // the above 2 conditionals can be refactored into 1
        // this reduces line number but also reduces readability and traceability
        // as we won't know which condition failed
        /* require(tweets[_user][_index].id == _index && tweets[_user][_index].likes > 0, "Tweet not found or has no likes"); */

        // index the specific tweet of the user using the _user and _index
        // tweets[_user][_index] give the Tweet instance whose the like field is to be updated
        tweets[_user][_index].likes--;

        // when a tweet is liked by a user we will trigger the TweetLiked event
        emit TweetUnliked(msg.sender, _user, _index, tweets[_user][_index].likes);
    }

    // NOTE: view functions are a type of function that only "view" or get some value
    // view functions don't alter any values of variables
}
