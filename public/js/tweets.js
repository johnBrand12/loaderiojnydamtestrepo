
const allReplyButtons = document.getElementsByClassName("hme-reply");
const allLikeButtons = document.getElementsByClassName("hme-like");
const allRetweetButtons = document.getElementsByClassName("hme-retweet");

Array.from(allReplyButtons).forEach((replyButtonElem) => {

    replyButtonElem.addEventListener('click', (e) => {

        e.preventDefault();
        console.log("looks like you clicked the reply button!");


    });

});


Array.from(allLikeButtons).forEach((likeButtonElem) => {

    likeButtonElem.addEventListener('click', (e) => {

        e.preventDefault();

        console.dir(e.target);

        const selectedTarget = e.target;

        const tweetId = e.target.attributes[2].value;
        const clientId = e.target.attributes[1].value;
    
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



// $(document).ready(function(){
//     $(".reply-thread").hide()

//     //reply tweets
//     $(".reply").click(function(){
//         var reply_id = $(this).attr('id').split('-')[2]
//         $('#reply-thread-'+reply_id).toggle()
//     })
    
//     //like tweets
//     $(".like").click(function(){
//         var tweet_id = $(this).attr('id').split('-')[2]
//         console.log($(this).attr('id'))
//         $.post(`/like-tweet/${tweet_id}`,function(data,status){
            
//             location.reload();
//             return false;
//         })
//     })

//     //retweet tweets 
//     $(".retweet").click(function(){
//         var retweet_id = $(this).attr('id').split('-')[2]
//         console.log($(this).attr('id'))
//         console.log("retweeted"+$(this).attr('id').split('-')[2])
//         $.post(`/retweet/${retweet_id}`,function(data,status){   
//             location.reload();
//             return false;
//         })
//     })
// })




