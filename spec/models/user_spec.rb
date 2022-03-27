require "spec_helper"
require "sinatra/activerecord"
require "active_record"

require('faker')

require_relative "../../models/tweet.rb"
require_relative "../../models/user.rb"
require_relative "../../models/mention.rb"
require_relative "../../models/following.rb"
require_relative "../../models/like.rb"


RSpec.describe User, :type => :model do
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
    end
  
    it 'Should report 7 users' do
      users = User.all
      expect(users.length).to eq(7)
    end

  end

  context 'testsuite2' do

    before(:all) do
      User.delete_all()
      30.times do |i|
          User.create(
              id: i + 1,
              username: Faker::Internet.user_name, 
              display_name: Faker::Internet.user_name, 
              email: Faker::Internet.email,
              password: Faker::Internet.password,
              active: true)
      end
    end
  
    it 'is valid' do
      users = User.all
      expect(users.length).to eq(30)
    end
  end
end