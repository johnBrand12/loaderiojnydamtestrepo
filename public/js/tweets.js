
const allReplyButtons = document.getElementsByClassName("hme-reply");
const allLikeButtons = document.getElementsByClassName("hme-like");
const allRetweetButtons = document.getElementsByClassName("hme-retweet");
const allReplySubmitButtons = document.getElementsByClassName('hme-reply-submit-button');

const nextPaginationButton = document.querySelector('.hme-next-button');
const pageNumSpanElement= document.querySelector('.hme-heading-pagenum');
const prevPaginationButton = document.querySelector('.hme-prev-button');

nextPaginationButton.addEventListener('click', () => {

    console.log("Looks you clicked on the next pagination button!");

    const pageNum = parseInt(pageNumSpanElement.textContent);
    const userId = parseInt(pageNumSpanElement.attributes[0].value);

    console.log("The page number is: ");

    console.log(pageNum);
    console.log(userId);

    let queriedPageNum = pageNum + 1; 

    console.log(queriedPageNum);

    fetch(`http://localhost:4567/feedpageservice/${userId}/${queriedPageNum}`)
    .then((res) => res.json())
    .then((res) => {

        console.log("The next pagination request was successful!");
        console.log(res);
    })
    .catch((err) => {

        console.log("The next pagination request was not successful");
        console.log(err);

    });


});

prevPaginationButton.addEventListener('click', () => {

    console.log("Looks like you clicked on the previous pagination button")

    fetch('http://localhost:4567/feedpageservice/:user_id/:pagenum')
    .then((res) => {


    })
    .catch((err) => {

    });


});


Array.from(allReplySubmitButtons).forEach((button) => {


    button.addEventListener('click', (e) => {

        e.preventDefault();

        const localTextAreaElem = e.target.parentNode.querySelector('.hme-reply-input-container');

        const tweetId = e.target.parentNode.parentNode.parentNode.querySelector('.hme-reply').attributes[3].value;
        const clientUserId = e.target.parentNode.parentNode.parentNode.querySelector('.hme-reply').attributes[2].value;
        const sessionUserId = e.target.parentNode.parentNode.parentNode.querySelector('.hme-reply').attributes[1].value;

        const replyTweetContent = localTextAreaElem.value;

        const options = {
            method: 'POST'
        };

        fetch(`http://localhost:4567/reply/${tweetId}/${sessionUserId}/${replyTweetContent}`, options)
        .then((res) => res.json())
        .then((res) => {

            console.log("The retweet was posted successfully");

            console.log(res);

            const retweetListContainer = e.target.parentNode.parentNode.querySelector('.hme-reply-component-container');
            console.log(retweetListContainer.attributes);

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

        console.log("the has pressed value is");

        console.log(hasPressed);

        if (hasPressed === 'false') {

            console.log("The initial if false check was certainly triggered");

            console.log(e.target.attributes);

            console.log(parentTweetId);
            console.log(sessionUserId);
    
            let cachedRetweets = await fetch(`http://localhost:4567/cachedretweets/${parentTweetId}/${sessionUserId}`);
    
            cachedRetweets = await cachedRetweets.json();
    
            console.log("The cached retweets list");
    
            console.log(cachedRetweets);

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
            // replyListContainer.style.display = 'none';

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

        const selectedTarget = e.target;

        const tweetId = e.target.attributes[3].value;
        const clientId = e.target.attributes[2].value;
    
        const options = {
            method: 'POST'
        };
    
        fetch(`http://localhost:4567/like-tweet/${tweetId}/${clientId}`, options)
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
    
        fetch(`http://localhost:4567/retweet/${tweetId}`, options)
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




