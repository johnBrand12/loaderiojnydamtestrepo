require "spec_helper"
require "sinatra/activerecord"
require "active_record"

require('faker')

require_relative "../../models/tweet.rb"
require_relative "../../models/user.rb"
require_relative "../../models/mention.rb"
require_relative "../../models/following.rb"
require_relative "../../models/retweet.rb"
require_relative "../../models/like.rb"

RSpec.describe Like, :type => :model do

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


    # want to convey that user 4, 5, and 6 liked tweet number 3, and users 1, 2 liked tweet number 2

    3.times do |id|
        Like.create!(
            id: id + 1,
            user_id: id + 4,
            tweet_id: 3
        )
    end

    2.times do |id|
        Like.create!(
            id: id + 4,
            user_id: id + 1,
            tweet_id: 2
        )
    end


  end

  it 'Should report that tweet number 3 have 3 likes on it' do
    sample_tweet = Tweet.find(3)
    expect(sample_tweet.likes.length).to eq(3)
  end

  it 'Should report that tweet number 2 has 2 likes on it ' do
    sample_tweet = Tweet.find(2)
    expect(sample_tweet.likes.length).to eq(2)
  end

end