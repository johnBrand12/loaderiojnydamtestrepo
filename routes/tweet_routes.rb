module Sinatra 
    module SampleApp
        module Routing
            module Tweets
                require 'colorize'
                def self.registered(app)

                    app.post '/create-tweet' do

                        authenticate!

                        redis_obj = settings.redis_instance
                        logger_obj = settings.logger_instance

                        start_ct_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        cur_user = session[:user]
                        Tweet.create(user_id:cur_user.id,text:params[:tweet])
                        ending_ct_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        @logger.info "Time elapsed for creating tweet: #{ending_ct_time-start_ct_time}".red
                        redirect "/home"
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

                    app.get '/cachedretweets/:parent_tweet_id' do






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