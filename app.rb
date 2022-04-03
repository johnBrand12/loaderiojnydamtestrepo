require "sinatra/base"

require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"
require "active_record"
require 'sinatra/flash'
require 'faker'

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

        
        if (params[:user_id] != nil) 

            session[:user] = User.find(params[:user_id].to_i)

        else
            authenticate! 
        end 

        @cur_user = User.find_by(username:session[:user].username)
        @feed = []
        followings = []
        @cur_user.fan_followings.each do |following|
            puts "This is the following"
            puts following.to_json
            followings.push(following.star.id)
        end
        @tweets = Tweet.all # create user feed
        @tweets.each do |tweet|
            if followings.include? tweet.user_id
                if @feed.size == 50
                    break
                end
                @feed.push(tweet)
            end
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



