require "sinatra/activerecord"
require "active_record"

require('faker')

require_relative "../../models/tweet.rb"
require_relative "../../models/user.rb"
require_relative "../../models/mention.rb"
require_relative "../../models/following.rb"
require_relative "../../models/tweetmentionmapping.rb"
require_relative "../../models/like.rb"

RSpec.describe Mention, :type => :model do

  before(:all) do

    dummy_users = ['Jack', 'Jill', 'Harry', 'Amanda', "Steven", "Carrol", "Marsh"]

    Like.delete_all()
    Retweet.delete_all()
    Tweetmentionmapping.delete_all()
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
        Mention.create!(
            id: id + 1,
            user_id: id + 1,
            tweet_id: id + 1,
        )
    end

    3.times do |id|
        Mention.create!(
            id: id + 4,
            user_id: id + 1,
            tweet_id: 4
        )
    end

    3.times do |id|
        Tweetmentionmapping.create!(
            id: id + 1,
            tweet_id: 4,
            mention_id: id + 4,
        )
    end

    3.times do |id|
        Tweetmentionmapping.create!(
            id: id + 4,
            tweet_id: id + 5,
            mention_id: 4
        )
    end

  end

  it 'Should report 3 mentions used that are in tweet id 4' do
    tweet = Tweet.find(4)
    mentions = tweet.tweetmentionmappings
    expect(mentions.length).to eq(3)
  end

  it 'Should report 1 mention (id 4) that is used in 4 tweets' do
    mention = Mention.find(4)
    tweets = mention.tweetmentionmappings
    expect(tweets.length).to eq(4)
  end

end