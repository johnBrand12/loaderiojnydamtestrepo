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
require_relative './lib/hashtag_processing'
require_relative './lib/mention_processing'
require_relative './lib/display_processing'

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

    set :root, File.dirname(__FILE__)

    use Rack::Session::Pool

    register Sinatra::Flash

    register Sinatra::SampleApp::Routing::Auth
    register Sinatra::SampleApp::Routing::FollowingRoutes
    register Sinatra::SampleApp::Routing::Search
    register Sinatra::SampleApp::Routing::Tweets
    register Sinatra::SampleApp::Routing::Test

    helpers Sinatra::Authentication
    helpers Sinatra::HashTagProcessing
    helpers Sinatra::MentionProcessing
    helpers Sinatra::DisplayProcessing

    helpers TweetActions

    set :public_folder, 'public'

    
   
    configure do
        @redis = Redis.new(url: 'redis://redistogo:1af524c39770f9e227ef0f94a3e6ac94@sole.redistogo.com:10663/')
        @logger = Logger.new(STDOUT)
        set :redis_instance, @redis
        set :logger_instance, @logger
    end


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

        redis_instance = settings.redis_instance

        
        if (params[:user_id] != nil) 

            if (!settings.redis_instance.get("user#{params[:user_id]}userobj"))
                session[:user] = User.find(params[:user_id].to_i)

                cached_user_object = session[:user].to_json

                settings.redis_instance.set("user#{params[:user_id]}userobj", cached_user_object)
                session[:user] = JSON.parse(cached_user_object)

            else
                
                cached_user_object = settings.redis_instance.get("user#{params[:user_id]}userobj")
                session[:user] = JSON.parse(cached_user_object)

            end
        else
            authenticate! 

        end 

        retrieved_followings = nil

        followings = []

        @cur_user = nil
        @feed = []

        if (!settings.redis_instance.get("user#{session[:user]["id"].to_s}followinglist"))

            @cur_user = User.find(session[:user]["id"].to_i);
            @feed = []

            if (@cur_user.fan_followings != nil)
                @cur_user.fan_followings.each do |following|
                    puts "This is the following"
                    puts following.to_json
                    followings.push(following.star.id)
                end
            end

            settings.redis_instance.set("user#{session[:user]["id"].to_s}followinglist", followings.to_json)

        else
            cached_following_list = settings.redis_instance.get("user#{session[:user]["id"].to_s}followinglist")
            retrieved_followings = JSON.parse(cached_following_list)
            followings = retrieved_followings
        end


        @tweets = []

        if (!settings.redis_instance.get("user#{session[:user]["id"].to_s}feedtweets"))

            @tweets = Tweet.all # create user feed
            @tweets.each do |tweet|
                if followings.include? tweet.user_id
                    if @feed.size == 50
                        break
                    end

                    modified_tweet_text = handle_mention_hashtag_parsing(tweet.text)

                    puts "modified tweet checkpoint"

                    prepared_tweet_obj = {
                        "id" => tweet.id,
                        "text" => modified_tweet_text,
                        "user_id" => tweet.user_id,
                        "display_name" => tweet.user.display_name,
                        "user_name" => tweet.user.username,
                        "tweet_id" => tweet.tweet_id,
                        "tweet_likes_length" => tweet.likes.length,
                        "tweet_retweets_length" =>  tweet.retweets.length,
                        "tweet_replies_length" => tweet.tweets.length,
                        "tweet_replies_array" => []
                    }

                    @feed.push(prepared_tweet_obj)
                end
            end

            settings.redis_instance.set("user#{session[:user]["id"].to_s}feedtweets", @feed.to_json)

        else
            cached_tweets = settings.redis_instance.get("user#{session[:user]["id"].to_s}feedtweets")
            if (cached_tweets != 'null')
                @feed = JSON.parse(cached_tweets)
            end
        end

        @user_id = session[:user]["id"].to_s
        @user_name = session[:user]["username"].to_s

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



