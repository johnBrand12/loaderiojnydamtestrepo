
const allReplyButtons = document.getElementsByClassName("hme-reply");
const allLikeButtons = document.getElementsByClassName("hme-like");
const allRetweetButtons = document.getElementsByClassName("hme-retweet");
const allReplySubmitButtons = document.getElementsByClassName('hme-reply-submit-button');

const nextPaginationButton = document.querySelector('.hme-next-button');
const pageNumSpanElement= document.querySelector('.hme-heading-pagenum');
const prevPaginationButton = document.querySelector('.hme-prev-button');
const leftVerticalTweetList = document.querySelector('.hme-tweet-left-vertical-component');
const rightVerticalTweetList = document.querySelector('.hme-tweet-right-vertical-component');

nextPaginationButton.addEventListener('click', () => {

    const pageNum = parseInt(pageNumSpanElement.textContent);
    const userId = parseInt(pageNumSpanElement.attributes[0].value);
    const sessionUserName = pageNumSpanElement.attributes[1].value;
    const sessionDisplayName = pageNumSpanElement.attributes[2].value;

    let queriedPageNum = pageNum + 1; 

    fetch(`/feedpageservice/${userId}/${queriedPageNum}`)
    .then((res) => res.json())
    .then((res) => {

        // parsing the tweets back into the DOM readable format

        let halfResLength = res.length / 2;

        // first for loop to populate the left container correctly 

        let verticalLeftTweets = [];
        let verticalRightTweets = [];

        for (let i = 0; i < halfResLength; i++) {

            let localTweetObj = res[i * 2];

            if (localTweetObj !== undefined) {

                let localTweet = `<div class="tweet" id=${localTweetObj.id}>
                <p><span class="fw-bold">${localTweetObj.display_name}</span><a href="/user/test">@${localTweetObj.user_name}</a></p>
                <p class="hme-text-container">${localTweetObj.text}</p>
                <div class="hme-button-container">
                    <button class="hme-reply hme-tweet-action-button" userid="${userId}" clientId="${localTweetObj.user_id}" id="${localTweetObj.id}" hasPressed="false"><i style="pointer-events:none"class="bi bi-chat"></i>${localTweetObj.tweet_replies_length}</button> 
                    <button class="hme-like hme-tweet-action-button" userid="${userId}" clientId="${localTweetObj.user_id}" id="${localTweetObj.id}" ><i style="pointer-events:none" class="bi bi-heart"></i> ${localTweetObj.tweet_likes_length}</button>  
                    <button class="hme-retweet hme-tweet-action-button" userid="${userId}" clientId="${localTweetObj.user_id}" id="${localTweetObj.id}" ><i style="pointer-events:none" class="bi bi-arrow-repeat"></i>${localTweetObj.tweet_retweets_length}</button> 
                </div>
                <div class="hme-replylist-container">  
                    <div class="hme-vertical-header">
                        <span class="hme-reply-prompt-header">Please leave a reply here</span>
                        <textarea class="hme-reply-input-container" placeholder="Leave something here"></textarea>
                        <button class="hme-reply-submit-button">Submit</button>
                    </div>
                    <hr>
                    <div 
                    sessionusername="${sessionUserName}"
                    sessiondisplayname="${sessionDisplayName}" 
                    class="hme-reply-component-container">
                    </div>
                </div>       
            </div>`;

            verticalLeftTweets += localTweet;

            }

        }

        // second for loop to populat the right container correctly 

        for (let i = 0; i < halfResLength; i++) {


            let localTweetObj = res[(i * 2) + 1];

            if (localTweetObj !== undefined) {


                let localTweet = `<div class="tweet" id=${localTweetObj.id}>
                    <p><span class="fw-bold">${localTweetObj.display_name}</span><a href="/user/test">@${localTweetObj.user_name}</a></p>
                    <p class="hme-text-container">${localTweetObj.text}</p>
                    <div class="hme-button-container">
                        <button class="hme-reply hme-tweet-action-button" userid="${userId}" clientId="${localTweetObj.user_id}" id="${localTweetObj.id}" hasPressed="false"><i style="pointer-events:none"class="bi bi-chat"></i>${localTweetObj.tweet_replies_length}</button> 
                        <button class="hme-like hme-tweet-action-button" userid="${userId}" clientId="${localTweetObj.user_id}" id="${localTweetObj.id}" ><i style="pointer-events:none" class="bi bi-heart"></i> ${localTweetObj.tweet_likes_length}</button>  
                        <button class="hme-retweet hme-tweet-action-button" userid="${userId}" clientId="${localTweetObj.user_id}" id="${localTweetObj.id}" ><i style="pointer-events:none" class="bi bi-arrow-repeat"></i>${localTweetObj.tweet_retweets_length}</button> 
                    </div>
                    <div class="hme-replylist-container">  
                        <div class="hme-vertical-header">
                            <span class="hme-reply-prompt-header">Please leave a reply here</span>
                            <textarea class="hme-reply-input-container" placeholder="Leave something here"></textarea>
                            <button class="hme-reply-submit-button">Submit</button>
                        </div>
                        <hr>
                        <div 
                        sessionusername="${sessionUserName}"
                        sessiondisplayname="${sessionDisplayName}" 
                        class="hme-reply-component-container">
                        </div>
                    </div>       
                </div>`;

                verticalRightTweets += localTweet;

            }

        }


        leftVerticalTweetList.innerHTML = verticalLeftTweets;
        rightVerticalTweetList.innerHTML = verticalRightTweets;
        pageNumSpanElement.textContent = queriedPageNum;
    })
    .catch((err) => {

        console.log("The next pagination request was not successful");
        console.log(err);

    });


});

prevPaginationButton.addEventListener('click', () => {

    const pageNum = parseInt(pageNumSpanElement.textContent);
    const userId = parseInt(pageNumSpanElement.attributes[0].value);
    const sessionUserName = pageNumSpanElement.attributes[1].value;
    const sessionDisplayName = pageNumSpanElement.attributes[2].value;

    let queriedPageNum = pageNum - 1; 

    fetch(`/feedpageservice/${userId}/${queriedPageNum}`)
    .then((res) => res.json())
    .then((res) => {

        // parsing the tweets back into the DOM readable format

        let halfResLength = res.length / 2;

        // first for loop to populate the left container correctly 

        let verticalLeftTweets = [];
        let verticalRightTweets = [];

        for (let i = 0; i < halfResLength; i++) {

            let localTweetObj = res[i * 2];

            if (localTweetObj !== undefined) {

                let localTweet = `<div class="tweet" id=${localTweetObj.id}>
                <p><span class="fw-bold">${localTweetObj.display_name}</span><a href="/user/test">@${localTweetObj.user_name}</a></p>
                <p class="hme-text-container">${localTweetObj.text}</p>
                <div class="hme-button-container">
                    <button class="hme-reply hme-tweet-action-button" userid="${userId}" clientId="${localTweetObj.user_id}" id="${localTweetObj.id}" hasPressed="false"><i style="pointer-events:none"class="bi bi-chat"></i>${localTweetObj.tweet_replies_length}</button> 
                    <button class="hme-like hme-tweet-action-button" userid="${userId}" clientId="${localTweetObj.user_id}" id="${localTweetObj.id}" ><i style="pointer-events:none" class="bi bi-heart"></i> ${localTweetObj.tweet_likes_length}</button>  
                    <button class="hme-retweet hme-tweet-action-button" userid="${userId}" clientId="${localTweetObj.user_id}" id="${localTweetObj.id}" ><i style="pointer-events:none" class="bi bi-arrow-repeat"></i>${localTweetObj.tweet_retweets_length}</button> 
                </div>
                <div class="hme-replylist-container">  
                    <div class="hme-vertical-header">
                        <span class="hme-reply-prompt-header">Please leave a reply here</span>
                        <textarea class="hme-reply-input-container" placeholder="Leave something here"></textarea>
                        <button class="hme-reply-submit-button">Submit</button>
                    </div>
                    <hr>
                    <div 
                    sessionusername="${sessionUserName}"
                    sessiondisplayname="${sessionDisplayName}" 
                    class="hme-reply-component-container">
                    </div>
                </div>       
            </div>`;

            verticalLeftTweets += localTweet;

            }

        }

        // second for loop to populat the right container correctly 

        for (let i = 0; i < halfResLength; i++) {


            let localTweetObj = res[(i * 2) + 1];

            if (localTweetObj !== undefined) {


                let localTweet = `<div class="tweet" id=${localTweetObj.id}>
                    <p><span class="fw-bold">${localTweetObj.display_name}</span><a href="/user/test">@${localTweetObj.user_name}</a></p>
                    <p class="hme-text-container">${localTweetObj.text}</p>
                    <div class="hme-button-container">
                        <button class="hme-reply hme-tweet-action-button" userid="${userId}" clientId="${localTweetObj.user_id}" id="${localTweetObj.id}" hasPressed="false"><i style="pointer-events:none"class="bi bi-chat"></i>${localTweetObj.tweet_replies_length}</button> 
                        <button class="hme-like hme-tweet-action-button" userid="${userId}" clientId="${localTweetObj.user_id}" id="${localTweetObj.id}" ><i style="pointer-events:none" class="bi bi-heart"></i> ${localTweetObj.tweet_likes_length}</button>  
                        <button class="hme-retweet hme-tweet-action-button" userid="${userId}" clientId="${localTweetObj.user_id}" id="${localTweetObj.id}" ><i style="pointer-events:none" class="bi bi-arrow-repeat"></i>${localTweetObj.tweet_retweets_length}</button> 
                    </div>
                    <div class="hme-replylist-container">  
                        <div class="hme-vertical-header">
                            <span class="hme-reply-prompt-header">Please leave a reply here</span>
                            <textarea class="hme-reply-input-container" placeholder="Leave something here"></textarea>
                            <button class="hme-reply-submit-button">Submit</button>
                        </div>
                        <hr>
                        <div 
                        sessionusername="${sessionUserName}"
                        sessiondisplayname="${sessionDisplayName}" 
                        class="hme-reply-component-container">
                        </div>
                    </div>       
                </div>`;

                verticalRightTweets += localTweet;

            }

        }


        leftVerticalTweetList.innerHTML = verticalLeftTweets;
        rightVerticalTweetList.innerHTML = verticalRightTweets;
        pageNumSpanElement.textContent = queriedPageNum;
    })
    .catch((err) => {

        console.log("The next pagination request was not successful");
        console.log(err);
    });


});


Array.from(allReplySubmitButtons).forEach((button) => {


    button.addEventListener('click', (e) => {

        e.preventDefault();

        const localTextAreaElem = e.target.parentNode.querySelector('.hme-reply-input-container');

        const tweetId = e.target.parentNode.parentNode.parentNode.querySelector('.hme-reply').attributes[3].value;
        const sessionUserId = e.target.parentNode.parentNode.parentNode.querySelector('.hme-reply').attributes[1].value;

        const replyTweetContent = localTextAreaElem.value;

        const options = {
            method: 'POST'
        };

        fetch(`/reply/${tweetId}/${sessionUserId}/${replyTweetContent}`, options)
        .then((res) => res.json())
        .then((res) => {

            const retweetListContainer = e.target.parentNode.parentNode.querySelector('.hme-reply-component-container');
            const sessionUsername = retweetListContainer.attributes[0].value;
            const sessionDisplayName = retweetListContainer.attributes[1].value;

            retweetListContainer.innerHTML += `<div class="hme-reply-component">
                <span class="hme-reply-component-headertext">${sessionUsername}@${sessionDisplayName}</span>
                <span>${replyTweetContent}</span>
            </div>`;

        })
        .catch((err) => {

            console.log("Something went wrong with adding the retweet");
            console.log(err);

        });


    });

});

Array.from(allReplyButtons).forEach((replyButtonElem) => {

    replyButtonElem.addEventListener('click', async (e) => {

        e.preventDefault();

        let parentTweetId = e.target.attributes[3].value;
        let sessionUserId = e.target.attributes[1].value;

        let hasPressed = e.target.attributes[4].value;

        if (hasPressed === 'false') {
    
            let cachedRetweets = await fetch(`/cachedretweets/${parentTweetId}/${sessionUserId}`);
    
            cachedRetweets = await cachedRetweets.json();

            const replyContainerReference = e.target.parentNode.parentNode.querySelector('.hme-reply-component-container')
    
            let listHtmlStringResult = "";

            cachedRetweets.forEach((cachedTweet) => {
    
                
                let localString = "";
                localString += `<div class="hme-reply-component">
                <span class="hme-reply-component-headertext">${cachedTweet.user_username}@${cachedTweet.user_display_name}</span>
                <span>${cachedTweet.text}</span>
                </div>
                `;

                listHtmlStringResult += localString;
            });

            replyContainerReference.innerHTML = listHtmlStringResult;

            e.target.attributes[4].value = 'true';
        }

        const replyListContainer = e.target.parentNode.parentNode.querySelector('.hme-replylist-container');
        const outerTweetContainer = e.target.parentNode.parentNode;

        if (outerTweetContainer.className == 'tweetexpanded') {

            outerTweetContainer.className = 'tweet';

        } else {

            replyListContainer.style.display = 'block';
            outerTweetContainer.className = "tweetexpanded";
        }

    });

});


Array.from(allLikeButtons).forEach((likeButtonElem) => {

    likeButtonElem.addEventListener('click', (e) => {

        e.preventDefault();

        console.dir(e.target);

        const tweetId = e.target.attributes[3].value;
        const clientId = e.target.attributes[2].value;
    
        const options = {
            method: 'POST'
        };
    
        fetch(`/like-tweet/${tweetId}/${clientId}`, options)
            .then((res) => res.json())
            .then((res) => {
    
                let prevLikeCount = parseInt(e.target.innerText.trim());

                prevLikeCount =  prevLikeCount +  1;

                e.target.innerHTML = `<i class="bi bi-heart"> ${prevLikeCount} `;
    
            })
            .catch((err) => {
            
                console.log(err);
            console.log("There was an error with the like request")
            });
})});


    // })


Array.from(allRetweetButtons).forEach((retweetButtonElem) => {

    retweetButtonElem.addEventListener('click', (e) => {
        e.preventDefault();

        const tweetId = e.target.getAttribute('id').value;
        const clientId = e.target.getAttribute('clientid').value;
    
        const options = {
            method: 'POST'
        };
    
        fetch(`/retweet/${tweetId}`, options)
        .then((res) => res.json())
        .then((res) => {
    
            console.log("The retweet request was received");
            console.log(res);
    
        })
        .catch((err) => {
    
           console.log("There was an error with the retweet request")
        })

    });
});




