module Sinatra 
    module SampleApp
        module Routing
            module FollowingRoutes
                def self.registered(app) 

                    app.get '/updatefollowing/:fanfollowing' do
                        authenticate!
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

                    app.get '/following/retrievelistcache' do

                        authenticate!
                        local_uid = params[:uid]

                        redis_obj = settings.redis_instance
                        logger_obj = settings.logger_instance

                        if (redis_obj.get("userfollowingobjectlistbyuserid#{session[:user]["id"].to_s}") == nil)

                            following_list_active_record = User.where(id: session[:user]["id"])[0].fan_followings

                            prepared_following_list = []

                            following_list_active_record.each do |following_obj|

                                prepared_following_obj = {
                                    
                                    "star_id" => following_obj.star.id,
                                    "star_username" => following_obj.star.username,
                                    "star_displayname" => following_obj.star.display_name,
    
                                }

                                prepared_following_list.push(prepared_following_obj)
                            end
                            return prepared_following_list.to_json
                        else
                            cached_followings = redis_obj.get("userfollowingobjectlistbyuserid#{session[:user]["id"].to_s}")
                            prepared_following_list = JSON.parse(cached_followings)
                            return prepared_following_list.to_json
                        end
                    end

                    app.post '/removefollowingservice' do

                        # TODO for when the user presses the unfollow button on the people page

                    end

                    app.post '/insertfollowingservice' do


                        authenticate!
                        # This endpoint will assume on the frontend that you can't
                        # follow someone that is already in the database cache, it will be clear

                        redis_obj = settings.redis_instance
                        logger_obj = settings.logger_instance


                        start = Time.now.to_i

                        session_var = session[:user]


                        req_body = JSON.parse(request.body.string)

                        if (redis_obj.get("userfollowingobjectlistbyuserid#{session[:user]["id"].to_s}") == nil)

                            # reconstructing cache from database which hopefully happens rarely

                            following_list_active_record = User.where(id: session[:user]["id"])[0].fan_followings

                            prepared_following_list = []

                            following_list_active_record.each do |following_obj|

                                prepared_following_obj = {
                                    
                                    "star_id" => following_obj.star.id,
                                    "star_username" => following_obj.star.username,
                                    "star_displayname" => following_obj.star.display_name,
    
                                }

                                prepared_following_list.push(prepared_following_obj)
                            end
                        else
                            cached_followings = redis_obj.get("userfollowingobjectlistbyuserid#{session[:user]["id"].to_s}")
                            prepared_following_list = JSON.parse(cached_followings)

                        end


                        # inserting the new following into the database as well as into the cache 
                        following = Following.create(star_id: req_body["star_id"].to_i , fan_id: session[:user]["id"])

                        if (following) 

                            following_obj = {

                                "star_id" => following.star.id,
                                "star_username" => following.star.username,
                                "star_displayname" => following.star.display_name,
                            }
    
                            prepared_following_list.push(following_obj)

                            redis_obj.set("userfollowingobjectlistbyuserid#{session[:user]["id"].to_s}", prepared_following_list.to_json)
                            end_time = Time.now.to_i
                            logger.info("Route: /insertfollowingservice Time: " + (end_time-start).to_s)
                            prepared_following_list.to_json
                        else
                            end_time = Time.now.to_i
                            logger.info("Route: /insertfollowingservice Time: " + (end_time-start).to_s)
                            400
                        end
                    end

                    # The /updatefollowers service endpoint but in the form of a service returning json
                
                    app.post '/updatefollowings/:fan_id/:star_id/:action' do

                        authenticate!


                        redis_obj = settings.redis_instance
                        logger_obj = settings.logger_instance


                        fan_id_param = params[:fan_id].to_i
                        star_id_param = params[:star_id].to_i
                        action_param = params[:action].to_s

                        if (action_param == "unfollow")

                            follow_destory_result = Following.where(star_id: star_id_param, fan_id: fan_id_param).destroy

                            if (follow_destory_result)

                                # update cache to reflect change

                                cached_following_list = JSON.parse(redis_obj.get("userfollowingobjectlistbyuserid#{fan_id_param.to_s}"))

                                local_delete_target = nil

                                cached_following_list.each_with_index do |following_entry, index|

                                    if (following_entry["star_id"] == star_id_param)

                                        local_delete_target = index
                                    end
                                end

                                if (local_delete_target != nil)
                                    cached_following_list.delete_at(local_delete_target)
                                end

                                redis_obj.set("userfollowingobjectlistbyuserid#{fan_id_param.to_s}", cached_following_list.to_json)

                            else
                                400
                            end


                        else

                            ## handling the case when the user wants to follow the follower 

                            ## TODO

                        end
                        
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

                        user_id = params[:user_id]
                        uid = params[:uid]

                        redis_obj = settings.redis_instance
                        logger_obj = settings.logger_instance

                        input_user_id = nil

                        if (user_id == nil)
                            authenticate!
                            input_user_id = params[:uid]
                        else   
                            input_user_id = params[:user_id]
                        end

                        if (redis_obj.get("userfollowingobjectlistbyuserid#{input_user_id.to_s}") == nil)

                            following_list_active_record = User.where(id: input_user_id)[0].fan_followings

                            prepared_following_list = []

                            following_list_active_record.each do |following_obj|

                                prepared_following_obj = {
                                    
                                    "star_id" => following_obj.star.id,
                                    "star_username" => following_obj.star.username,
                                    "star_displayname" => following_obj.star.display_name,
    
                                }

                                prepared_following_list.push(prepared_following_obj)

                            end

                            redis_obj.set("userfollowingobjectlistbyuserid#{input_user_id.to_s}", prepared_following_list.to_json)

                            @followings_list = prepared_following_list
                            
                            string = "checkpoint"
                        else

                            cached_following_list = redis_obj.get("userfollowingobjectlistbyuserid#{input_user_id.to_s}")

                            @followings_list = JSON.parse(cached_following_list)

                        end

                        end_time = Time.now.to_i
                        logger.info("Route: /following Time: " + (end_time-start).to_s) 
                        erb(:following)
                        
                    end
    
                    app.get '/followers' do  #protected 

                        user_id = params[:user_id]
                        uid = params[:uid]

                        redis_obj = settings.redis_instance 
                        logger_obj = settings.logger_instance 

                        start = Time.now.to_i
                        input_user_id = nil

                        if (user_id == nil)
                            authenticate!
                            input_user_id = params[:uid]
                        else   
                            input_user_id = params[:user_id]
                        end

                        if (redis_obj.get("userfollowerobjectlistbyuserid#{input_user_id.to_s}") == nil)

                            follower_list_active_record = User.where(id: input_user_id)[0].star_followings

                            prepared_follower_list = []

                            follower_list_active_record.each do |follower_obj|

                                prepared_follower_obj = {
                                    
                                    "fan_id" => follower.obj.fan.id,
                                    "fan_username" => follower_obj.fan.username,
                                    "fan_displayname" => follower_obj.fan.display_name,
    
                                }

                                prepared_follower_list.push(prepared_follower_obj)

                            end

                            redis_obj.set("userfollowerobjectlistbyuserid#{input_user_id.to_s}", prepared_follower_list.to_json)

                            @followers_list = prepared_follower_list
                            
                            string = "checkpoint"
                        else

                            cached_follower_list = redis_obj.get("userfollowerobjectlistbyuserid#{input_user_id.to_s}")

                            @followers_list = JSON.parse(cached_follower_list)

                        end

                        end_time = Time.now.to_i
                        logger.info("Route: /followers Time: " + (end_time-start).to_s) 
                        erb(:followers)
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