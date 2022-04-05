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
                        @logger = Logger.new($stdout)

                        puts "These are the params"
                        redis_obj = settings.redis_instance 
    
                        param_obj = params


                        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        if user = User.authenticate(params, redis_obj)
                            puts user
                            session[:user] = user #user.authenticate does not return the full user from the database
                            end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                            @logger.info "User #{session[:user]["id"]} was authenticated in #{end_time - start_time} units"
                            redirect_to_original_request
                        else
                            flash[:danger] = "Sign in failed. Incorrect username or password"
                            redirect '/login'
                        end
                        
                    end
    
    
                    app.get '/register' do 
                        @logger = Logger.new($stdout)
                        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        erb :signup, :layout => false
                        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        @logger.info "The register page was loaded in #{end_time - start_time} time units"
                    end
                    
                    app.post '/signup' do 
                        @logger = Logger.new($stdout)
                        start = Time.now.to_i
                        newUser = User.new({username: params[:username],display_name: params[:display_name],email: params[:email],password: params[:password],active: true})
                        if(newUser.valid? and (params[:password] == params[:pw_confirm]))
                            my_password = BCrypt::Password.create(params[:password])
                            User.create({username: params[:username],display_name: params[:display_name],email: params[:email],password: my_password,active: true})
                            session[:user] = newUser
                            redirect "/user/#{params[:username]}"
                        else 
                            if((params[:password] != params[:pw_confirm]))
                                flash[:notice] = newUser.errors.full_messages.join("\r\n") + " Passwords do not match. Please try again."
                            else  
                                flash[:notice] = newUser.errors.full_messages.join("\r\n")
                            end
                        end_time = Time.now.to_i
                        @logger.info("Route: /signup Time: " + (end_time-start))
                            redirect '/register'
                        end
                    
                    end 
                
                
                    app.get '/user/:name' do #protected

                        @logger = Logger.new($stdout)
                        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        if (params[:user_id] != nil)   
                            session[:user] = User.find(params[:user_id].to_i)
                        else
                            authenticate! 
                        end 
                        @user = User.find_by(username:params[:name])
                        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        @logger.info "Route: /user/:name  Time: #{end_time-start}"
                        erb(:profile)

    
                    end


                end

            end
        end
    end
end