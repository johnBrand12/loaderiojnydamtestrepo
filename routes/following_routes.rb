module Sinatra 
    module SampleApp
        module Routing
            module FollowingRoutes
                def self.registered(app) 

                    app.get '/updatefollowing/:fanfollowing' do
                        start = Time.now.to_i
                        following = Following.find_by(id: params[:fanfollowing]) 

                        if(following.fan_active == true)
                            following.update(fan_active: false)
                        else
                            following.update(fan_active: true)
                        end
                        end_time = Time.now.to_i
                        logger.info("Route: /updatefollowing/:fanfollowing Time: " + (end_time-start))
                        redirect '/following'
                    end

                    app.post '/insertfollowingservice' do
                        start = Time.now.to_i
                        req_body = JSON.parse(request.body)

                        following = Following.create(star_id: req_body["star_id"].to_i , fan_id: session[:user].id , fan_active: true)

                        if (following) 
                            result_object = {
                                following_id: following.id
                            }
                            result_object.to_json
                        else
                            400
                        end

                        end_time = Time.now.to_i
                        logger.info("Route: /insertfollowingservice Time: " + (end_time-start))
                    end

                    # The /updatefollowers service endpoint but in the form of a service returning json
                
                    app.get '/updatefollowers/:fanfollowing' do
                        start = Time.now.to_i
                        following = Following.find_by(id: params[:fanfollowing])
                        if(following.fan_active == true)
                            following.update(fan_active: false) 
                        else
                            following.update(fan_active: true) 
                        end
                        end_time = Time.now.to_i
                        logger.info("Route: /updatefollowers/:fanfollowing Time: " + (end_time-start))
                        redirect '/followers'
                    end
                
                    app.get '/insertfollowing' do
                        start = Time.now.to_i
                        Following.create(star_id: params[:starid] ,fan_id: params[:fanid] , fan_active: true)
                        end_time = Time.now.to_i
                        logger.info("Route: /insertfollowing Time: " + (end_time-start))
                        redirect '/followers'
                    end
    
    
                    app.get '/following' do
                        start = Time.now.to_i
                        authenticate!
                        @user = User.find_by(username: session[:user].username)
                        erb(:following)
                        end_time = Time.now.to_i
                        logger.info("Route: /following Time: " + (end_time-start)) 
                        
                    end
    
                    app.get '/followers' do  #protected 
                        start = Time.now.to_i
                        authenticate!
                        @user = User.find_by(username: session[:user].username)
                        erb(:followers)
                        end_time = Time.now.to_i
                        logger.info("Route: /followers Time: " + (end_time-start)) 
                    end

                end
            end
        end
    end
end




#logger.info("Params to route: /updatefollowing/:fanfollowing" + params[:fanfollowing].to_s
#+ "by user: " + session[:user_id].to_s)
#logger.info("Looking for user in Following table @ timestamp: " + Time.now.to_i
#+ "by user" + session[:user_id])
# logger.error("Fan_active is true: Update failed for user: " + session[:user_id].to_s)
# logger.error("Fan_active is false: Update failed for user: " + session[:user_id].to_s)
# logger.info("End request to route /updatefollowing/:fanfollowing @ timestamp: " + Time.now.to_i
#     + "by user: " + session[:user_id].to_s)
#     logger.info("User found @ timestamp: " + Time.now.to_i)