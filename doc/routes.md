# NanoTwitter Routes


## Front End Routes Page Serving Routes

GET /register

This route serves up the register erb page

GET /login

This route serves up the login - in erb page

GET /innersignin

This route serves up the inner sign - in erb page

GET /home

This route serves up the home page integrated with layout template 

GET /user/:name

This route serves up the profile page integrated with layout template 

GET /search

This route serves up the explore page integrated with layout template 

GET /followers

This route serves up the followers page integrated with layout template 

GET /notifications

This route serves up the notifications page integrated with layout template 



## Back End Functional Routes


POST /register

This route will handle the form submittal action once the user has pressed
The “submit” button on the register page. 

POST /login

This route will handle the form submittal action once the users has pressed
The “Sign in” button on the login page

POST /logout

This route will handle the user's request to be logged out of the system. 
This will eventually navigate the user back to the signin/register page.

POST /tweets/:userId

This route will handle the action when a user has created a new tweet

POST /retweets/:tweetId/:userId

This route will handle the action when a user has created a new tweet which
Is a retweet of a previous tweet

POST /tweets/like/:tweetId/:userId

This route will handle the action when a user has liked a specific tweet

POST /tweets/comment/:tweetId/:userId

This route will handle the action when a user has commented on  a specific tweet

POST /users/followers/:targetUserId/:sourceUserId

This route will handle the action when a user follows another user. (It will internally establish
The star relationship as well)

GET /tweets/feed/:userId

This route will handle the action when the user is on the home page and will retrieve the feed/timeline. (Requirements
Specify last 50 tweets I believe)

GET /search/?phrase=

This route will handle the action when the user is on the explore page and searches for a particular phrase. It will
Retrieve tweets that correspond to that particular phrase. 

GET /users/followings/:userId

This route will handle the action when the given user wants to see all the people that they are following. 

GET /users/stars/:userId

This route will handle the action when the given user wants to see all the people who are following them (stars)



