require "sinatra/base"

require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "active_record"
require 'sinatra/flash'
require 'faker'
require 'redis'
require 'json'
require 'bunny'

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
        # We need to put the redis url into an environment variable later
        @redis = Redis.new(url: 'redis://redistogo:1af524c39770f9e227ef0f94a3e6ac94@sole.redistogo.com:10663/')
        @logger = Logger.new(STDOUT)
        rabbit_conn = Bunny.new("amqps://nablsufn:ygexIYKT-cCeSkMJj_UdmU1tYGk5At_x@shark.rmq.cloudamqp.com/nablsufn")
        rabbit_conn.start

        @rabbit_channel = rabbit_conn.create_channel
        @rabbit_queue = @rabbit_channel.queue("tweetobjectsrequest")

        set :redis_instance, @redis
        set :logger_instance, @logger
        set :rabbit_channel_instance, @rabbit_channel
        set :rabbit_queue_instance, @rabbit_queue

    end


    get '/' do
        if (session[:user] || params[:user_id])
            if (params[:user_id])
                redirect "/home?user_id=#{params[:user_id].to_s}"
            else
                redirect "/home"
            end
        else
            erb :outersignin, :layout => false
        end
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

        puts "These are the followings at this time"

        puts followings


        @tweets = []

        if (!settings.redis_instance.get("user#{session[:user]["id"].to_s}feedtweets"))

            cached_feed_ten_pages = []

            # an optimization could be created here to only with all the tweets of the people 
            # that they follow, not the entire database

            @tweets = []

            followings.each do |following_num|

                sub_tweet_list = Tweet.where(user_id: following_num.to_i).limit(50)

                puts "This is a checkpoint to analyze the sub tweet array"

                @tweets.push(*sub_tweet_list)

            end

            puts "This is the checkpoint to have the final active record array of tweets"

            ## old code to retrieve all the tweets

            # @tweets = Tweet.all 
            @tweets.each_with_index do |tweet, index|

                if (followings.include? tweet.user_id) && (cached_feed_ten_pages.size < 500)

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

                    if @feed.size < 51
                        @feed.push(prepared_tweet_obj)
                    end

                    cached_feed_ten_pages.push(prepared_tweet_obj)
                end
            end

            puts "This is the cached ten pages checkpoint"

            settings.redis_instance.set("user#{session[:user]["id"].to_s}feedtweets", @feed.to_json)
            settings.redis_instance.set("user#{session[:user]["id"].to_s}feedtweetstenpages", cached_feed_ten_pages.to_json)

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

    # after do
    #     ActiveRecord::Base.clear_active_connections!
    # end

    

    run! if app_file == $0


end



