$(document).ready(function(){
    $(".reply-thread").hide()

    //reply tweets
    $(".reply").click(function(){
        var reply_id = $(this).attr('id').split('-')[2]
        $('#reply-thread-'+reply_id).toggle()
    })
    
    //like tweets
    $(".like").click(function(){
        var tweet_id = $(this).attr('id').split('-')[2]
        console.log($(this).attr('id'))
        $.post(`/like-tweet/${tweet_id}`,function(data,status){
            
            location.reload();
            return false;
        })
    })

    //retweet tweets 
    $(".retweet").click(function(){
        var retweet_id = $(this).attr('id').split('-')[2]
        console.log($(this).attr('id'))
        console.log("retweeted"+$(this).attr('id').split('-')[2])
        $.post(`/retweet/${retweet_id}`,function(data,status){   
            location.reload();
            return false;
        })
    })
})


