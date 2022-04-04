require "sinatra/base"

require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "active_record"
require 'sinatra/flash'
require 'faker'
require 'redis'
require 'json'

require_relative './lib/authentication'
require_relative './lib/tweet_actions'

require_relative "./models/user.rb"
require_relative "./models/hashtag.rb"
require_relative "./models/like.rb"
require_relative "./models/mention.rb"
require_relative "./models/retweet.rb"
require_relative "./models/tweet.rb"
require_relative "./models/tweethashmapping.rb"
require_relative "./models/tweetmentionmapping.rb"
require_relative "./models/following.rb"

require_relative "./routes/auth_routes"
require_relative "./routes/following_routes"
require_relative "./routes/search_routes"
require_relative "./routes/tweet_routes"
require_relative "./routes/test_routes"
require 'logger'


class SimpleApp < Sinatra::Base 
    logger = Logger.new(STDOUT)

    set :root, File.dirname(__FILE__)

    use Rack::Session::Pool

    register Sinatra::Flash

    register Sinatra::SampleApp::Routing::Auth
    register Sinatra::SampleApp::Routing::FollowingRoutes
    register Sinatra::SampleApp::Routing::Search
    register Sinatra::SampleApp::Routing::Tweets
    register Sinatra::SampleApp::Routing::Test

    helpers Sinatra::Authentication
    helpers TweetActions

    set :public_folder, 'public'

    
   
    configure do
        @redis = Redis.new(url: 'redis://redistogo:1af524c39770f9e227ef0f94a3e6ac94@sole.redistogo.com:10663/')
        set :redis_instance, @redis
    end


    @logger = Logger.new($stdout)

    get '/' do
        if session[:user]
            redirect "/home"
        else
            erb :outersignin, :layout => false
        end
    end

    get '/master' do
        authenticate!
        @tweets = Tweet.all
        erb(:master) 
    end

    get '/home' do 
     #protected

        puts 'this is the connection'

        redis_instance = settings.redis_instance

        
        if (params[:user_id] != nil) 

            puts "The user id is #{params[:user_id]}"

            # if (!redis.get(""))
            #     session[:user] = User.find(params[:user_id].to_i)
            # end

            if (!settings.redis_instance.get("user#{params[:user_id]}userobj"))
                session[:user] = User.find(params[:user_id].to_i)

                cached_user_object = session[:user].to_json

                settings.redis_instance.set("user#{params[:user_id]}userobj", cached_user_object)
                puts "this is the session user"
                session[:user] = JSON.parse(cached_user_object)

            else
                
                cached_user_object = settings.redis_instance.get("user#{params[:user_id]}userobj")
                session[:user] = JSON.parse(cached_user_object)

            end
        else
            authenticate! 
        end 

        retrieved_followings = nil

        if (!settings.redis_instance.get("user#{params[:user_id]}followinglist"))

            @cur_user = User.find(params[:user_id].to_i);
            @feed = []
            followings = []
            @cur_user.fan_followings.each do |following|
                puts "This is the following"
                puts following.to_json
                followings.push(following.star.id)
            end

            settings.redis_instance.set("user#{params[:user_id]}followinglist", followings.to_json)

        else
            cached_following_list = settings.redis_instance.get("user#{params[:user_id]}followinglist")
            retrieved_followings = JSON.parse(cached_following_list)
        end

        ## assuming backend invalidation hasn't taken place yet



        if (!settings.redis_instance.get("user#{params[:user_id]}feedtweets"))

            @tweets = Tweet.all # create user feed
            @tweets.each do |tweet|
                if followings.include? tweet.user_id
                    if @feed.size == 50
                        break
                    end
                    @feed.push(tweet)
                end
            end

            settings.redis_instance.set("user#{params[:user_id]}feedtweets", @feed.to_json)

        else
            cached_tweets = settings.redis_instance.get("user#{params[:user_id]}feedtweets")
            @feed = JSON.parse(cached_tweets)
        end

        erb(:home)
    end


    get '/notifications' do  #protected 
        authenticate!
        erb(:notifications)
    end

    after do
        ActiveRecord::Base.clear_active_connections!
    end

    

    run! if app_file == $0


end



