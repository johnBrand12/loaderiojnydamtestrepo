module Sinatra 
    module SampleApp
        module Routing
            module Search

                def self.registered(app)
                    app.get '/search' do     #protected 
                        @logger = Logger.new($stdout)
                        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        authenticate!
                        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        @logger.info "#{session[:user].id} was authenticated in #{end_time - start_time}"
                        erb(:explore)
                    end
                
                    app.get '/search/:phrase' do
                        @logger = Logger.new($stdout)
                        authenticate!
                        query_phrase = params[:phrase]
                        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        @tweets = Tweet.select{|x| x.text[query_phrase] != nil}
                        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
                        @logger.info "User #{session[:user].id} searched for tweets in #{end_time - start_time} time units"
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