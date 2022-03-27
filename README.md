# nanotwitter

Group #4 -> Jasmyne Jean-Remy, Aarti Jain, John Nydam
heroku link: https://nanotwitter4.herokuapp.com/

tests for nanotwitter stage 2:
![image](https://user-images.githubusercontent.com/17534604/153964637-166f48fb-9962-44cb-9dce-1b124675db68.png)

tests for nanotwitter stage 5:
<img width="448" alt="Screen Shot 2022-03-13 at 10 34 53 AM" src="https://user-images.githubusercontent.com/77457932/158064543-a6670055-3d8f-41b6-802f-748afe1a8389.png">

Version Change History


nt0.6 - (T) NT Test Framework

- Implemented the testing routes as described by the assignment specification
- Converted our classic Sinatra app into a modular one, allowing for the usage and division of routes into multiple files
- Started work on an option Search Users Page

Contributions:

We divided the assignment by assigning ourselves to the required test routes

GET /test/reset?user_count=u (John)
GET /test/tweet?tweet_user=x&tweet_count=y (John)
GET /test/status (Jasmyne)
GET /test/corrupted?user_count=u (Jasmyne)
GET /test/stress?n=n&star=u1&fan=u2 (Aarti)

nt0.5 - (T) NT Core

- Implemented tweet creation, like, and retweet functionality, also implemented basic reply functionality (chaining) 
  (Contribution by Jasmyne)
- Implemented Following functionality. 
  (Contribution by Aarti)
- Implemented searching tweets by text functionality, and created explore page
  (Contribution by John)

nt0.4 - (T) Authentication
- Implemented Authentication (Login, Sign Up, sessions, BCrypt)
- Improved UI from last assignment
- Changed Routing

(Joint Contribution -- concurrent attempt on 3 dev branches)

nt0.3 - (T) UI

- Implemented the initial/dummy pages for the app. 
- This is includes but may not be limited the signin process page flow, the register page, as well as the inner tabular pages including the home page, explore page, notifications page, profile page, and followers page. 

- Initial pages have been implemented, and UI sketches have been placed in the respective docs folder

Contributions:
-- Sign-in Pages, Explore Page (John)
-- Register Page, Profile Page (Aarti)
-- Home Page, Layout Framework for Dashboard, Tweet Creation Modals (Jasmyne)


nt0.2 - (T) Storage

- Set up database, migrations, models, and wrote unit tests for the associations. Deployed application to heroku. 
  (Joint Contribution)

nt0.1 - (T) Begin

- Set up the private github repo, and designed database schemas for nanotwitter
  (Joint Contribution)


Known Bugs:

- We have temporarily created a flag to keep track of followers and followings of certain users. 
- we plan to update the logic such that the following relations are eventually deleted. We will need a search user page for that which we plan to implement.
