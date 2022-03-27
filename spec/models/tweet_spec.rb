require "spec_helper"
require "sinatra/activerecord"
require "active_record"

require('faker')

require_relative "../../models/tweet.rb"
require_relative "../../models/user.rb"
require_relative "../../models/mention.rb"
require_relative "../../models/following.rb"
require_relative "../../models/like.rb"

RSpec.describe Tweet, :type => :model do

    context 'testsuite1' do

        before(:all) do

            dummy_users = ['Jack', 'Jill', 'Harry', 'Amanda', "Steven", "Carrol", "Marsh"]

            Like.delete_all()
            Retweet.delete_all()
            Mention.delete_all()
            Tweet.delete_all()
            Following.delete_all()
            User.delete_all()

            dummy_users.each_with_index do |user, index|
                User.create(
                    id: (index + 1),
                    username: user, 
                    display_name: Faker::Internet.user_name, 
                    email: Faker::Internet.email,
                    password: Faker::Internet.password,
                    active: true)
            end


            3.times do |id|
                Tweet.create!(
                    id: id + 1, 
                    text: Faker::Lorem.paragraph_by_chars(number:rand(1..180),supplemental: false), #generating the text for the tweet
                    user_id: 4,
                    created_at: Faker::Time.between_dates(from: Date.today - 365, to: Date.today, period: :all) #==> when the tweet was created
                )
            end

            3.times do |id|
                Tweet.create!(
                    id: id + 4, 
                    text: Faker::Lorem.paragraph_by_chars(number:rand(1..180),supplemental: false), #generating the text for the tweet
                    user_id: 6,
                    created_at: Faker::Time.between_dates(from: Date.today - 365, to: Date.today, period: :all) #==> when the tweet was created
                )
            end


        end

        it 'Should report 3 tweets that were made by Amanda (userid 4)' do
            amanda_user = User.find(4)
            expect(amanda_user.tweets.length).to eq(3)
        end

        it 'Should report 3 tweets that were made by Carroll (userid 6)' do
            carroll_user = User.find(6)
            expect(carroll_user.tweets.length).to eq(3)
        end
    end


    context 'testsuite2' do

        before(:all) do
            Retweet.delete_all()
            Like.delete_all()
            Tweet.delete_all() 
            User.delete_all()
    
            15.times do |i|
                User.create(
                    id: i + 1,
                    username: Faker::Internet.user_name, 
                    display_name: Faker::Internet.user_name, 
                    email: Faker::Internet.email,
                    password: Faker::Internet.password,
                    active: true
                )
            end
    
            User.all.each do |user|
    
                user.tweets.create(text:Faker::Lorem.paragraph_by_chars(number:rand(1..180),supplemental: false))
                user.tweets.create(text:Faker::Lorem.paragraph_by_chars(number:rand(1..180),supplemental: false))
                user.tweets.create(text:Faker::Lorem.paragraph_by_chars(number:rand(1..180),supplemental: false))
            end
    
            Tweet.all.each do |tweet|
                rand(1..50).times do |i|
                    tweet.likes.create(user_id:rand(1..15))
                end
                rand(1..50).times do |i|
                    tweet.retweets.create(user_id:rand(1..15))
                end
            end
        end
    
        it "created users" do
            users = User.all 
            expect(users.length).to eq(15) 
        end
    
        it "created tweets" do 
            tweets = Tweet.all
            expect(tweets.length).to eq(15*3)
        end
    
        it "tweets have likes and retweets" do
            Tweet.all.each do |tweet|
                expect(tweet.likes.length).not_to eq(0)
                expect(tweet.retweets.length).not_to eq(0)
            end
        end
    end

end