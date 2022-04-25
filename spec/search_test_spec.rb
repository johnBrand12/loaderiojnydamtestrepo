require "sinatra/activerecord"
require "active_record"

require 'test/spec'
require 'rack/test'
require 'rspec/core'

require('faker')
require('bcrypt')

require_relative '../app.rb'

require_relative "../models/tweet.rb"
require_relative "../models/user.rb"
require_relative "../models/mention.rb"
require_relative "../models/following.rb"
require_relative "../models/like.rb"
require_relative "../models/retweet.rb"

RSpec.describe 'Search Functionality Endpoints' do

    def app
        SimpleApp
    end

    include Test::Unit::Assertions
    include Rack::Test::Methods

    before(:all) do

        Like.delete_all()
        Retweet.delete_all()
        Mention.delete_all()
        Tweet.delete_all()
        User.delete_all()
        Following.delete_all()

        
        User.create!(
            id: 51,
            username: "@jnydam",
            display_name: "John Nydam",
            email: "jnydam@brandeis.edu",
            password: BCrypt::Password.create("testpassword"),
            active: true
        )

        User.create!(
            id: 52,
            username: "@samsomeone",
            display_name: "Sam Someone",
            email: "samsomeone@test.com",
            password: BCrypt::Password.create("somepassword"),
            active: true
        )

        User.create!(
            id: 53,
            username: "@jaketanney",
            display_name: "Jake Tanney",
            email: "jaketanney@gmail.com",
            password: BCrypt::Password.create("somepassword"),
            active: true
        )

        User.create!(
            id: 54,
            username: "@superstar",
            display_name: "Super Star",
            email: "superstar@gmail.com",
            password: BCrypt::Password.create("somepassword"),
            active: true
        )

        
        Following.create!(
            id: 201,
            star_id: 51,
            fan_id: 52
        );

        Following.create!(
            id: 202,
            star_id: 51,
            fan_id: 53
        );

        Following.create!(
            id: 203,
            star_id: 54,
            fan_id: 51
        );


        (1..20).each do |id|
            Tweet.create!(
        # each tweet is assigned an id from 1-100
                id: id, 
                text: Faker::Lorem.paragraph_by_chars(number:rand(1..180),supplemental: false), #generating the text for the tweet
                user_id: 53,
                created_at: Faker::Time.between_dates(from: Date.today - 365, to: Date.today, period: :all) #==> when the tweet was created
            )
        end

        Tweet.create!(
            id: 21,
            text: "how are you today? I saw the superbowl yesterday textwhichwillappeartwice. And this is the end of the sentence",
            user_id: 51,
            created_at: Faker::Time.between_dates(from: Date.today - 365, to: Date.today, period: :all) 
        )


        Tweet.create!(
            id: 22,
            text: "textwhichwillappeartwice this is some extra text",
            user_id: 51,
            created_at: Faker::Time.between_dates(from: Date.today - 365, to: Date.today, period: :all) 
        )

    end

    it "Testing internal search functionality -- Should report that John (user 51) has 2 followers" do

        test_tweets = Tweet.select{|x| x.text["textwhichwillappeartwice"] != nil}
        assert test_tweets.count == 2

    end

    it "Should report that the POST /search endpoint returns a json result containing the 2 tweets constructed above" do

        post '/search?phrase=textwhichwillappeartwice&user_id=1'
        attributes = JSON.parse(last_response.body)
        expect(attributes.length).to eq(2)

    end

end