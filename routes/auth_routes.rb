module Sinatra 
    module SampleApp
        module Routing
            module Auth

                require 'colorize'
                def self.registered(app) 
                    
                    app.get '/logout' do    
                        session[:user] = nil
                        puts 'User has been signe out'.red
                        redirect '/login'
                    end
                
                    app.get '/login' do
                        puts 'On Login page'.blue
                        erb :innersignin, :layout => false
                
                    end
                
                    app.get '/innersigninpost' do 
                        logger_obj = settings.logger_instance

                        puts "These are the params"
                        redis_obj = settings.redis_instance 
    
                        param_obj = params


                        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        if user = User.authenticate(params, redis_obj)
                            puts user
                            session[:user] = user #user.authenticate does not return the full user from the database
                            end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                            logger_obj.info "User #{session[:user]["id"]} was authenticated in #{end_time - start_time} units"
                            redirect_to_original_request
                        else
                            flash[:danger] = "Sign in failed. Incorrect username or password"
                            redirect '/login'
                        end
                        
                    end
    
    
                    app.get '/register' do 
                        logger_obj = settings.logger_instance
                        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        logger_obj.info "The register page was loaded in #{(end_time - start_time).to_s} time units"
                        erb :signup, :layout => false
                    end
                    
                    app.post '/signup' do 

                        logger_obj = settings.logger_instance
                        redis_obj = settings.redis_instance 
    
                        start = Time.now.to_i
                        newUser = User.new({username: params[:username],display_name: params[:display_name],email: params[:email],password: params[:password],active: true})
                        if(newUser.valid? and (params[:password] == params[:pw_confirm]))

                            my_password = BCrypt::Password.create(params[:password])

                            newly_created_user = User.create({username: params[:username], display_name: params[:display_name], email: params[:email],password: my_password, active: true})

                            prepared_user_obj = {
                                "id" => newly_created_user.id,
                                "username" => newly_created_user.username,
                                "display_name" => newly_created_user.display_name,
                                "email" => newly_created_user.email,
                                "password" => newly_created_user.password,
                                "active" => newly_created_user.active
                            }

                            session[:user] = prepared_user_obj

                            redirect "/user/#{params[:username]}"
                        else 
                            if((params[:password] != params[:pw_confirm]))
                                flash[:notice] = newUser.errors.full_messages.join("\r\n") + " Passwords do not match. Please try again."
                            else  
                                flash[:notice] = newUser.errors.full_messages.join("\r\n")
                            end
                        end_time = Time.now.to_i
                        logger_obj.info("Route: /signup Time: " + (end_time-start).to_s)
                            redirect '/register'
                        end
                    
                    end 
                
                
                    app.get '/user/:name' do #protected

                        logger_obj = settings.logger_instance

                        redis_obj = settings.redis_instance 

                        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        if (params[:user_id] != nil && redis_obj.get("userbyid#{params[:user_id].to_s}") != nil)   
                            cached_user_obj = redis_obj.get("userbyid#{params[:user_id].to_s}")
                            session[:user] = JSON.parse(cached_user_obj)
                        else
                            authenticate! 
                        end 

                        user_active_record = nil

                        if (redis_obj.get("userbyusername#{params[:name].to_s}") == nil)
                            
                            user_active_record = User.find_by(username:params[:name])

                            string = "checkpoint"
                            
                            prepared_user_obj = {
                                "id" => user_active_record.id,
                                "username" => user_active_record.username,
                                "display_name" => user_active_record.display_name,
                                "email" => user_active_record.email,
                                "password" => user_active_record.password,
                                "active" => user_active_record.active
                            }

                            redis_obj.set("userbyusername#{params[:name].to_s}", prepared_user_obj.to_json)
                            @user = prepared_user_obj

                        else

                            cached_user_obj = redis_obj.get("userbyusername#{params[:name].to_s}")
                            @user = JSON.parse(cached_user_obj)

                        end

                        string = "breakpoint"

                        # dealing with the star following count cache 
                        if (redis_obj.get("userstarfollowingcountbyid#{@user["id"]}") == nil)


                            star_following_count = User.find_by(username:params[:name]).star_followings.count
                            redis_obj.set("userstarfollowingcountbyid#{@user["id"]}", star_following_count.to_s)
                            @userstarfollowingcount = star_following_count

                        else

                            star_following_count = redis_obj.get("userstarfollowingcountbyid#{@user["id"]}")
                            @userstarfollowingcount = star_following_count

                        end

                        string = "checkpoint"


                        # dealing with the user fan following count cache 

                        if (redis_obj.get("userfanfollowingcountbyid#{@user["id"]}") == nil)


                            fan_following_count = User.find_by(username:params[:name]).fan_followings.count
                            redis_obj.set("userfanfollowingcountbyid#{@user["id"]}", fan_following_count.to_s)
                            @userfanfollowingcount = fan_following_count

                        else

                            fan_following_count = redis_obj.get("userfanfollowingcountbyid#{@user["id"]}")
                            @userfanfollowingcount = fan_following_count

                        end

                        string = "breakpoint"

                        # dealing with the initial user tweet list cache

                        if (redis_obj.get("usertweetlistbyid#{@user["id"]}") == nil)

                            user_tweet_list_active_record = User.find_by(username:params[:name]).tweets

                            prepared_tweet_list = []

                            user_tweet_list_active_record.each do |tweet|

                                tweet_likes_length = tweet.likes.length
                                tweet_retweets_length = tweet.retweets.length

                                modified_tweet_text = handle_mention_hashtag_parsing(tweet.text)

                                puts "modified tweet checkkpoint"

                                tweet_obj = {
                                    "id" => tweet.id,
                                    "text" => modified_tweet_text,
                                    "user_id" => tweet.user_id,
                                    "tweet_id" => tweet.tweet_id,
                                    "created_at" => tweet.created_at,
                                    "updated_at" => tweet.updated_at,
                                    "tweet_likes_length" => tweet_likes_length.to_s,
                                    "tweet_retweets_length" => tweet_retweets_length.to_s
                                }

                                prepared_tweet_list.push(tweet_obj)

                            end

                            redis_obj.set("usertweetlistbyid#{@user["id"]}", prepared_tweet_list.to_json)
                            @usertweets = prepared_tweet_list

                        else

                            cached_user_tweets = redis_obj.get("usertweetlistbyid#{@user["id"]}")
                            @usertweets = JSON.parse(cached_user_tweets)

                        end

                        string = "breakpoint"

                        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        logger_obj.info "Route: /user/:name  Time: #{(end_time-start).to_s}"
                        erb(:profile)

    
                    end
                end
            end
        end
    end
end