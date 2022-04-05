module Sinatra 
    module SampleApp
        module Routing
            module Search

                def self.registered(app)

                    app.get '/search' do     #protected 


                        puts "this is the search route"


                        @logger = Logger.new($stdout)
                        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        authenticate!
                        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        @logger.info "#{session[:user].id} was authenticated in #{end_time - start_time}"
                        erb(:explore)
                    end
                
                    app.get '/searchphrase' do

                        @logger = Logger.new($stdout)

                        redis_obj = settings.redis_instance 
                        logger_obj = settings.logger_instance 

                        @user_id = params[:user_id].to_s

                        if (@user_id == nil)
                            authenticate!
                            @user_id = session[:user].id
                        end

                        query_phrase = params[:phrase]
                        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        @tweets = []

                        adjusted_tweets = []

                        if (!redis_obj.get("phrase-#{query_phrase.to_s}"))

                            @tweets = Tweet.select{|x| x.text[query_phrase] != nil}

                            @tweets.each do |tweet_entry|

                                adjusted_tweet_hash = {

                                    "id" => tweet_entry.id,
                                    "text" => tweet_entry.text,
                                    "user_display_name" => tweet_entry.user.display_name,
                                    "user_user_name" => tweet_entry.user.username,
                                    "tweet_reply_length" => tweet_entry.tweets.length,
                                    "tweet_likes_length" => tweet_entry.likes.length,
                                    "tweet_retweet_length" => tweet_entry.retweets.length
                                }

                                adjusted_tweets.push(adjusted_tweet_hash)

                            end

                            @tweets = adjusted_tweets

                            redis_obj.set("phrase-#{query_phrase.to_s}", @tweets.to_json)

                        else

                            cached_tweet_results = redis_obj.get("phrase-#{query_phrase.to_s}")
                            @tweets = JSON.parse(cached_tweet_results)

                        end
                        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        @logger.info "User #{@user_id} searched for tweets in #{end_time - start_time} time units"
                        erb(:exploreresults)
                    end
    
                    app.get '/people' do
                        authenticate!
                        erb(:people)
                    end

                    ## NOT A REQUIRED ROUTE FOR PROJECT
                    # Will modularize into a service that will connect with main app -- json
                    app.get '/search/friends/:username' do

                        following_statuses = []

                        authenticate!
                        query_name = params[:username]
                        users = User.select{|x| x.display_name[query_name] != nil}

                        users.each do |user|
                            begin
                                following_relation = Following.find_by(fan_id: session[:user].id, star_id: user.id)
                                if (following_relation) 
                                    following_statuses.append(true)
                                else
                                    following_statuses.append(false)
                                end
                            rescue => exception
                                following_statuses.append(false)
                            end
                        end

                        new_users = users.each_with_index.map {|user, index| {
                            display_name: user.display_name, 
                            id: user.id, 
                            is_following: following_statuses[index]}}

                        new_users.to_json
                    end
                end
            end
        end
    end
end