module Sinatra 
    module SampleApp
        module Routing
            module Tweets
                require 'colorize'
                def self.registered(app)
                    app.post '/create-tweet' do
                        @logger = Logger.new($stdout)
                        start_ct_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        cur_user = session[:user]
                        Tweet.create(user_id:cur_user.id,text:params[:tweet])
                        ending_ct_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        @logger.info "Time elapsed for creating tweet: #{ending_ct_time-start_ct_time}".red
                        redirect "/home"
                    end
    
                    app.post '/like-tweet/:tweet' do
                        @logger = Logger.new($stdout)
                        start_lt_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        cur_user = session[:user]
                        tweet = Tweet.find(params[:tweet])
                        #usr = User.find(params[:user_id])
                        tweet.likes.create(user_id:session[:user].id)
                        ending_lt_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        @logger.info "Time elapsed for Liking Tweet: #{ending_lt_time-start_lt_time}".red
                    end
    
                    app.post '/retweet/:tweet' do 
                        @logger = Logger.new($stdout)
                        start_rt_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        cur_user = session[:user]
                        tweet = Tweet.find(params[:tweet])
                        tweet.retweets.create(user_id:session[:user].id)
                        ending_rt_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        @logger.info "Time elapsed for retweeting tweet: #{ending_rt_time-start_rt_time}".red
                    end
    
                    app.post '/reply/:tweet' do
                        @logger = Logger.new($stdout)
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