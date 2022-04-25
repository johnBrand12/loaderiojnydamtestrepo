require 'csv'
require 'json'
require "faker"

module Sinatra
    module SampleApp
        module Routing
            module Test
                def self.registered(app)

                    app.get '/loaderio-89d195117aac48758a81638e7f0c784f.txt' do
                        puts "This is a test to see if loader works"
                        send_file 'loaderio-89d195117aac48758a81638e7f0c784f.txt'
                    end

                    app.get '/test/loadersearchphrase' do
                        send_file 'loaderio-payload.json'
                    end

                    app.get '/test/loaderuser' do
                        send_file 'loaderiouser.json'
                    end

                    app.get '/test/rotateuserhome' do
                        send_file 'loaderiorotateusersearchurl.json'
                    end

                    app.get '/test/status' do
                        @user_count =  User.all.length 
                        @tweet_count = Tweet.all.length 
                        @follows_count = Following.all.length
                        @test_user = User.find_by(username:"testuser")
                        erb(:status,:layout=>false)
                    end
                    
                    app.get '/test/corrupted' do
                        @user_sample = User.all.sample(params[:user_count].to_i)
                        @corrupted = []
                        @user_sample.each do |user|
                            tweets_corrputed = false
                            user.tweets.each do |tweet|
                                if tweet.corrupted? 
                                    tweets_corrputed = true
                                    break
                                end
                            end
                            @corrupted.push([user.id,user.corrupted?,tweets_corrputed])
                         end
                       
                        erb(:corrupted_test,:layout=>false)
                    end

                    app.get '/test/tweet' do

                        given_user_id = params[:user_id]
                        given_tweet_count = params[:count]

                        selected_user = nil
                        
                        num_id = given_user_id.to_i
                        num_count = given_tweet_count.to_i

                        rabbit_channel_obj = settings.rabbit_channel_instance
                        rabbit_queue_obj = settings.rabbit_queue_instance

                        ## code to handle scalable writes


                        # num_count.times do |i|

                        #     puts "This is the i"

                        #     # local_tweet_info = {
                        #     #     "text" => "This is a random tweet text which works with the debugger",
                        #     #     "user_id" => num_id,
                        #     #     "created_at" => "Random created at for debugging purposes"
                        #     # }

                        #     local_tweet_info = {
                        #         "text" => Faker::Lorem.paragraph_by_chars(number:rand(1..180),supplemental: false),
                        #         "user_id" => num_id,
                        #         "created_at" => Faker::Time.between_dates(from: Date.today - 365, to: Date.today, period: :all)
                        #     }

                        #     requested_tweet_array.push(local_tweet_info)
                        # end

                        begin
                            selected_user = User.find(num_id)
                        rescue => exception
                            400
                        end

                        if (selected_user) 

                            tweet_creation_request = {
                                "num_id" => num_id,
                                "num_count" => num_count
                            }

                            rabbit_channel_obj.default_exchange.publish(tweet_creation_request.to_json, routing_key: rabbit_queue_obj.name)
                            200
                        else
                            400    
                        end
                    end

                    app.get '/test/reset' do

                        Tweet.delete_all()
                        Following.delete_all()
                        User.delete_all()

                        users = CSV.parse(File.read("./db/users.csv"), headers: false)
                        tweets = CSV.parse(File.read("./db/tweets.csv"),headers: false)
                        follows = CSV.parse(File.read("./db/follows.csv"),headers: false)

                        given_num_users = params[:user_count].to_i

                        users.map! { |id, name| {"id" => id, "name" => name}}
                        tweets.map! { |id, content, date| {"user_id" => id, "content" => content, "date" => date}}
                        follows.map! {|fan_id, star_id| {"fan_id" => fan_id, "star_id" => star_id}}

                        rand_num_array = []

                        given_num_users.times do
                            num = rand(1...1000)
                            rand_num_array.append(num)
                        end

                        new_users = []
                        new_tweets = []
                        new_follow_relations = []
                        new_follow_users = []


                        # creating and keeping track of specified users
                        rand_num_array.each_with_index do |num, index|


                            new_user = User.create(
                                id: num,
                                username:users[num - 1]["name"].downcase,
                                display_name:users[num - 1]["name"],
                                email:"#{users[num - 1]["name"]}@email.com",
                                password:BCrypt::Password.create("password"),
                                active:true
                            )

                            new_users.append(new_user)

                            tweets.each do |tweet|

                                if (tweet["user_id"] == (num).to_s) 
                                    new_tweet = Tweet.create(
                                        text: tweet["content"],
                                        user_id: tweet["user_id"],
                                        created_at: tweet["date"],
                                        updated_at: tweet["date"]
                                    )

                                    new_tweets.append(new_tweet)
                                end
                            end

                            follows.each do |follow_relation|

                                if (follow_relation["fan_id"] == (num).to_s)

                                    new_follow_relation = Following.create(
                                        star_id: follow_relation["star_id"],
                                        fan_id: follow_relation["fan_id"]
                                    )

                                    new_follow_relations.append(new_follow_relation)

                                    follow_reference_num = follow_relation["star_id"].to_i

                                    new_follow_user = User.create(
                                        id: follow_reference_num,
                                        username:users[follow_reference_num - 1]["name"].downcase,
                                        display_name:users[follow_reference_num - 1]["name"],
                                        email:"#{users[follow_reference_num - 1]["name"]}@email.com",
                                        password:BCrypt::Password.create("password"),
                                        active:true
                                    )

                                    new_follow_users.append(new_follow_user)

                                end

                            end

                        end

                        # making sure test user is included after reset

                        User.create(
                            username: "testuser",
                            display_name: "testuser",
                            active: true,
                            email: "testuser@gmail.com",
                            password: BCrypt::Password.create("password")
                        )

                        json_response = {
                            users: new_users,
                            tweets: new_tweets,
                            relations: new_follow_relations,
                            followed_users: new_follow_users
                        }
                        json_response.to_json

                    end

                    app.get '/test/stress' do 
                        #Step 1: make sure this fan and star are present in the table
                        following = Following.find_by(star_id: params[:star],fan_id: params[:fan])        
                         #Step 2: if fan is present, then check if fan_active is true for this fan 
                        if(Following.exists?(star_id: params[:star], fan_id: params[:fan]))
                            if(following.fan_active == false)
                                #Step 3: if not true, change fan_active to true
                                following.update(fan_active: true) 
                            end
                
                        else
                            #Step 4: if fan is not present in table, insert fan & star into table 
                            Following.create({star_id: params[:star],fan_id: params[:fan],fan_active: true})
                        end
                
                        tweetContents = Array.new
                        tweetIds = Array.new
                        #have the user create n tweets using Faker
                        count = params[:n].to_i-1
                        for i in 0..count do
                            tweetBody = Faker::Lorem.paragraph_by_chars(number:rand(1..180),supplemental:false)
                            #for any n, call the route we created to post a tweet with this star id and some random Faker generated sentence
                            cur_user = params[:star]
                            tweet = Tweet.create(user_id:cur_user,text:tweetBody)
                            #store tweet content in array here 
                            tweetContents.append(tweetBody)
                            #store tweet id in different array here
                            tweetIds.append(tweet.id)
                        end 
                
                
                        #query the backend for those same ids (using the profile page logic)
                        Tweet.where(["user_id = ?", params[:star]]).find_each(order: :desc) do |tweet|
                            if(tweetIds.include? tweet[:id])
                                puts tweet[:text]
                            end
                        end
                        
                        #query timeline of fan, check that new tweets are listed
                
                        @cur_user = User.find_by(id: params[:fan])
                        @feed = []
                        followings = []
                        @cur_user.fan_followings.each do |following|
                            followings.push(following.star.id)
                        end
                        @tweets = Tweet.all # create user feed
                        @tweets.each do |tweet|
                            if (followings.include? tweet.user_id) && (tweetIds.include? tweet[:id]) then
                                if @feed.size == 50
                                    break
                                end
                                @feed.push(tweet)
                            end
                        end
                
                        puts @feed.inspect
                    end
                end

            end
        end
    end
end