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
    
                    app.post '/reply/:tweet' do

                        authenticate!

                        redis_obj = settings.redis_instance
                        logger_obj = settings.logger_instance

                        start_reply_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        cur_user = session[:user]
                        tweet = Tweet.find(params[:tweet])
                        tweet.tweets.create(user_id:cur_user.id,text:params[:reply])
                        ending_reply_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        @logger.info "Time elapsed for replying to tweet: #{ending_reply_time-start_reply_time}".red

                    end

                end
            end
        end
    end
end