module Sinatra 
    module SampleApp
        module Routing
            module Tweets
                require 'colorize'
                def self.registered(app)


                    app.get '/feedpageservice/:user_id/:pagenum' do

                        redis_obj = settings.redis_instance
                        logger_obj = settings.logger_instance

                        user_id_param = params[:user_id].to_i

                        page_num_param = params[:pagenum].to_i

                        followings = []

                        if (!settings.redis_instance.get("user#{session[:user]["id"].to_s}followinglist"))

                            @cur_user = User.find(session[:user]["id"].to_i);
                            @feed = []
                
                            if (@cur_user.fan_followings != nil)
                                @cur_user.fan_followings.each do |following|
                                    puts "This is the following"
                                    puts following.to_json
                                    followings.push(following.star.id)
                                end
                            end
                
                            settings.redis_instance.set("user#{session[:user]["id"].to_s}followinglist", followings.to_json)
                
                        else
                            cached_following_list = settings.redis_instance.get("user#{session[:user]["id"].to_s}followinglist")
                            followings = JSON.parse(cached_following_list)
                        end

                        puts "This is the current following representation"

                        puts followings

                        cached_feed_ten_pages = []

                        if (redis_obj.get("user#{session[:user]["id"].to_s}feedtweetstenpages") == nil)

                            @tweets = Tweet.all # create user feed
                            @feed = []
                            @tweets.each_with_index do |tweet, index|

                                puts "The index is #{index}"

                                puts "The tweet is #{tweet}"
                                if (followings.include? tweet.user_id) && (cached_feed_ten_pages.size < 500)
                
                                    modified_tweet_text = handle_mention_hashtag_parsing(tweet.text)
                
                                    puts "modified tweet checkpoint"
                
                                    prepared_tweet_obj = {
                                        "id" => tweet.id,
                                        "text" => modified_tweet_text,
                                        "user_id" => tweet.user_id,
                                        "display_name" => tweet.user.display_name,
                                        "user_name" => tweet.user.username,
                                        "tweet_id" => tweet.tweet_id,
                                        "tweet_likes_length" => tweet.likes.length,
                                        "tweet_retweets_length" =>  tweet.retweets.length,
                                        "tweet_replies_length" => tweet.tweets.length,
                                        "tweet_replies_array" => []
                                    }
                
                                    if @feed.size < 51
                                        @feed.push(prepared_tweet_obj)
                                    end
                
                                    cached_feed_ten_pages.push(prepared_tweet_obj)
                                end
                            end
                            redis_obj.set("user#{session[:user]["id"].to_s}feedtweetstenpages", cached_feed_ten_pages.to_json)

                            puts "new cache checkpoint"

                            cached_feed_ten_pages.to_json 
                        else
                            cached_feed_ten_pages = JSON.parse(redis_obj.get("user#{session[:user]["id"].to_s}feedtweetstenpages"))

                            puts "intemediary checkpoint"

                            ending_index = 0
                            starting_index = (page_num_param - 1) * 50

                            if (((page_num_param - 1) * 50) + 49) >= cached_feed_ten_pages.size
                                ending_index = cached_feed_ten_pages.size - 1
                            else
                                ending_index = ((page_num_param - 1) * 50) + 49
                            end

                            puts "new checkpoint here"

                            paginated_feed = cached_feed_ten_pages[(starting_index)...(ending_index)]
                            paginated_feed.to_json
                        end  
                    end

                    app.post '/create-tweet' do

                        authenticate!
                        start_ct_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

                        redis_obj = settings.redis_instance
                        logger_obj = settings.logger_instance
                        
                        tweet_content_param = params[:tweet]


                        ## handling hashtag instances 

                        array_of_hashtag_instances = process_hashtags(tweet_content_param)

                        if (array_of_hashtag_instances.count != 0)

                            if (redis_obj.get("userid#{session[:user]["id"]}hashtaglist") == nil)

                                list_of_hashtags = []

                                array_of_hashtag_instances.each do |hashtag_string|

                                    raw_text = hashtag_string[1, hashtag_string.length]

                                    puts "Checkpoint"
                                    new_hashtag_obj = Hashtag.create(text: raw_text.to_s)

                                    if (new_hashtag_obj)
                                        list_of_hashtags.push(hashtag_string)
                                    else
                                        400
                                    end
                                end 

                                redis_obj.set("userid#{session[:user]["id"]}hashtaglist", list_of_hashtags.to_json)

                            else
                                cached_user_hashtag_list = JSON.parse(redis_obj.get("userid#{session[:user]["id"]}hashtaglist"))

                                ## Currently does not support hashtag uniqueness in the cache, we can refactor later

                                array_of_hashtag_instances.each do |hashtag_string|

                                    raw_text = hashtag_string[1, hashtag_string.length]

                                    new_hashtag_obj = Hashtag.create(text: raw_text.to_s)
                                    if (new_hashtag_obj)
                                        
                                        cached_user_hashtag_list.push(hashtag_string)
                                    else
                                        400
                                    end
                                end

                                redis_obj.set("userid#{session[:user]["id"]}hashtaglist", cached_user_hashtag_list.to_json)
                            end
                        end

                        puts "checkpoint"

                        if (redis_obj.get("usertweetlistbyid#{session[:user]["id"]}") == nil)

                            user_tweet_list_active_record = Tweet.where(user_id: session[:user]["id"])

                            prepared_tweet_list = []

                            user_tweet_list_active_record.each do |tweet|

                                tweet_likes_length = tweet.likes.length
                                tweet_retweets_length = tweet.retweets.length


                                tweet_obj = {
                                    "id" => tweet.id,
                                    "text" => tweet.text,
                                    "user_id" => tweet.user_id,
                                    "tweet_id" => tweet.tweet_id,
                                    "created_at" => tweet.created_at,
                                    "updated_at" => tweet.updated_at,
                                    "tweet_likes_length" => tweet_likes_length.to_s,
                                    "tweet_retweets_length" => tweet_retweets_length.to_s
                                }

                                prepared_tweet_list.push(tweet_obj)

                            end

                            redis_obj.set("usertweetlistbyid#{session[:user]["id"]}", prepared_tweet_list.to_json)
                            usertweets = prepared_tweet_list

                        else

                            cached_user_tweets = redis_obj.get("usertweetlistbyid#{session[:user]["id"]}")
                            usertweets = JSON.parse(cached_user_tweets)

                        end

                        # logic to create the new tweet and add it to the cache 

                        new_created_tweet = Tweet.create(user_id: session[:user]["id"], text:params[:tweet])

                        puts "checkpoint"

                        if (new_created_tweet)

                            ## handling mention instances 
                            array_of_mention_instances = process_mentions(tweet_content_param)

                            if (array_of_mention_instances == nil) 
                                return 400
                            else

                                if (array_of_mention_instances.count != 0)

                                    if (redis_obj.get("userid#{session[:user]["id"]}mentionlist") == nil)

                                        list_of_mentions = []

                                        array_of_mention_instances.each do |mention_string|

                                            ## need to find the corresponding user here
                                            raw_text = mention_string[1, mention_string.length]

                                            mention_user_obj = User.where(username: raw_text)[0]

                                            new_mention_obj = Mention.create(user_id: mention_user_obj.id, tweet_id: new_created_tweet.id)

                                            if (new_mention_obj)

                                                list_of_mentions.push(mention_string)

                                            else
                                                400
                                            end
                                        end

                                        # save the json list of mentions used to a cache

                                        redis_obj.set("userid#{session[:user]["id"]}mentionlist", list_of_mentions.to_json)
                                        
                                    else

                                        cached_user_mention_list = JSON.parse(redis_obj.get("userid#{session[:user]["id"]}mentionlist"))

                                        ## Currently does not support mention uniqueness in the cache, we can refactor later

                                        array_of_mention_instances.each do |mention_string|

                                            raw_text = mention_string[1, mention_string.length]
        
                                            new_mention_obj = Mention.create(text: raw_text.to_s)

                                            if (new_mention_obj)
                                                
                                                cached_user_mention_list.push(mention_string)
                                            else
                                                400
                                            end
                                        end
        
                                        redis_obj.set("userid#{session[:user]["id"]}hashtaglist", cached_user_mention_list.to_json)

                                    end
                                end
                            end

                            tweet_likes_length = new_created_tweet.likes.length
                            tweet_retweets_length = new_created_tweet.retweets.length

                            prepared_tweet_obj = {
                                "id" => new_created_tweet.id,
                                "text" => new_created_tweet.text,
                                "user_id" => new_created_tweet.user_id,
                                "tweet_id" => new_created_tweet.tweet_id,
                                "created_at" => new_created_tweet.created_at,
                                "updated_at" => new_created_tweet.updated_at,
                                "tweet_likes_length" => tweet_likes_length.to_s,
                                "tweet_retweets_length" => tweet_retweets_length.to_s
                            }

                            usertweets.push(prepared_tweet_obj)
                            redis_obj.set("usertweetlistbyid#{session[:user]["id"]}", usertweets.to_json)
                            ending_ct_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                            logger_obj.info "Time elapsed for creating tweet: #{ending_ct_time-start_ct_time}".red
                            redirect "/home"
                        else
                            ending_ct_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                            logger_obj.info "Time elapsed for creating tweet: #{ending_ct_time-start_ct_time}".red
                            400
                        end
                    end
    
                    app.post '/like-tweet/:tweet_id/:user_id' do

                        authenticate!

                        redis_obj = settings.redis_instance
                        logger_obj = settings.logger_instance

                        tweet_id_param = params[:tweet_id]
                        user_id_param = params[:user_id]

                        start_lt_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

                        tweet = nil

                        if (Like.where(user_id: user_id_param.to_i, tweet_id: tweet_id_param.to_i).count == 0)

                            tweet = Tweet.find(tweet_id_param.to_i)
                            tweet.likes.create(user_id: user_id_param.to_i)

                            # to invalidate all caches -- we can work on this later so that every time a write happens we don't invalidate all caches
                            redis_obj.flushall
                            response = {
                                "status" => "The like request was successfully received!"
                            }
                            ending_lt_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                            logger_obj.info "Time elapsed for Liking Tweet: #{(ending_lt_time-start_lt_time).to_s}".red
                            response.to_json
                        else
                            ending_lt_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                            logger_obj.info "Time elapsed for Liking Tweet: #{(ending_lt_time-start_lt_time).to_s}".red
                            400
                        end
                    end
    
                    app.post '/retweet/:tweet' do 

                        authenticate!

                        redis_obj = settings.redis_instance
                        logger_obj = settings.logger_instance

                        start_rt_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        cur_user = session[:user]
                        tweet = Tweet.find(params[:tweet])
                        tweet.retweets.create(user_id:session[:user].id)
                        ending_rt_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        @logger.info "Time elapsed for retweeting tweet: #{ending_rt_time-start_rt_time}".red
                    end

                    app.get '/cachedretweets/:parent_tweet_id/:user_id' do

                        authenticate!

                        redis_obj = settings.redis_instance
                        logger_obj = settings.logger_instance

                        parent_tweet_id_param = params[:parent_tweet_id]
                        user_id_param = params[:user_id]

                        if (redis_obj.get("userid#{user_id_param.to_s}tweetid#{parent_tweet_id_param.to_s}retweetslist") == nil)

                            retweets = Tweet.where(user_id: user_id_param.to_i, tweet_id: parent_tweet_id_param.to_i).last(20)
                            
                            prepared_retweet_list = []

                            retweets.each do |retweet_obj|

                                prepared_retweet_obj = {
                                    "id" => retweet_obj.id,
                                    "text" => retweet_obj.text,
                                    "user_id" => retweet_obj.user_id,
                                    "user_display_name" => retweet_obj.user.display_name,
                                    "user_username" => retweet_obj.user.username,
                                    "parent_tweet_id" => retweet_obj.tweet_id,
                                    "created_at" => retweet_obj.created_at.to_s,
                                    "updated_at" => retweet_obj.updated_at.to_s
                                }

                                prepared_retweet_list.push(prepared_retweet_obj)


                            end
                            
                            redis_obj.set("userid#{user_id_param.to_s}tweetid#{parent_tweet_id_param.to_s}retweetslist", prepared_retweet_list.to_json)
                            puts "Checkpoint"
                            prepared_retweet_list.to_json

                        else
                            puts "Checkpoint"
                            cached_retweets_list = redis_obj.get("userid#{user_id_param.to_s}tweetid#{parent_tweet_id_param.to_s}retweetslist")
                            cached_retweets_list
                        end
                    end
    
                    app.post '/reply/:tweet_id/:user_id/:text_content' do

                        authenticate!

                        start_reply_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

                        redis_obj = settings.redis_instance
                        logger_obj = settings.logger_instance

                        tweet_id_param = params[:tweet_id]
                        user_id_param = params[:user_id]
                        text_content_param = params[:text_content]

                        tweet_active_record = Tweet.find(tweet_id_param.to_i)

                        new_tweet_obj = tweet_active_record.tweets.create(user_id: user_id_param.to_i ,text: text_content_param.to_s) 

                        if (new_tweet_obj)
                            
                            # Update the feed cache to reflect 

                            if (redis_obj.get("userid#{user_id_param.to_s}tweetid#{tweet_id_param.to_s}retweetslist") == nil)

                                retweets = Tweet.where(user_id: user_id_param.to_i, tweet_id: tweet_id_param.to_i).last(20)

                                prepared_retweet_list = []

                                retweets.each do |retweet_obj|

                                    prepared_retweet_obj = {
                                        "id" => retweet_obj.id,
                                        "text" => retweet_obj.text,
                                        "user_id" => retweet_obj.user_id,
                                        "user_display_name" => retweet_obj.user.display_name,
                                        "user_username" => retweet_obj.user.username,
                                        "parent_tweet_id" => retweet_obj.tweet_id,
                                        "created_at" => retweet_obj.created_at.to_s,
                                        "updated_at" => retweet_obj.updated_at.to_s
                                    }

                                    prepared_retweet_list.push(prepared_retweet_obj)


                                end

                                redis_obj.set("userid#{user_id_param.to_s}tweetid#{tweet_id_param.to_s}retweetslist", prepared_retweet_list.to_json)

                                puts "Checkpoint"
                            else

                                cached_retweets_list = JSON.parse(redis_obj.get("userid#{user_id_param.to_s}tweetid#{tweet_id_param.to_s}retweetslist"))
                                new_prepared_retweet = {

                                    "id" => new_tweet_obj.id,
                                    "text" => new_tweet_obj.text,
                                    "user_id" => new_tweet_obj.user_id,
                                    "user_display_name" => new_tweet_obj.user.display_name,
                                    "user_username" => new_tweet_obj.user.username,
                                    "parent_tweet_id" => new_tweet_obj.tweet_id,
                                    "created_at" => new_tweet_obj.created_at.to_s,
                                    "updated_at" => new_tweet_obj.updated_at.to_s
                                }

                                cached_retweets_list.push(new_prepared_retweet)

                                redis_obj.set("userid#{user_id_param.to_s}tweetid#{tweet_id_param.to_s}retweetslist", cached_retweets_list.to_json)
                            end
                            response = {
                                "status" => "Successfully added the new retweet"
                            }
                            ending_reply_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                            logger_obj.info "Time elapsed for replying to tweet: #{ending_reply_time-start_reply_time}".red
                            response.to_json
                        else
                            ending_reply_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                            logger_obj.info "Time elapsed for replying to tweet: #{ending_reply_time-start_reply_time}".red
                            404
                        end
                    end
                end
            end
        end
    end
end