require "sinatra/activerecord"
require "active_record"

require('faker')

require_relative "../../models/tweet.rb"
require_relative "../../models/retweet.rb"
require_relative "../../models/user.rb"
require_relative "../../models/mention.rb"
require_relative "../../models/following.rb"
require_relative "../../models/like.rb"

RSpec.describe Retweet, :type => :model do

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

    3.times do |id|
        Retweet.create!(
            id: id + 1,
            tweet_id: 5,
            user_id: id + 1
        )
    end


  end

  it 'Should report that tweet (id 5) has bee retweeted 3 times' do
    sample_tweet = Tweet.find(5)
    retweets = sample_tweet.retweets
    expect(retweets.length).to eq(3)
  end


end