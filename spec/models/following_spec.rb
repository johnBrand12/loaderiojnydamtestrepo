require "sinatra/activerecord"
require "active_record"

require('faker')

require_relative "../../models/tweet.rb"
require_relative "../../models/user.rb"
require_relative "../../models/mention.rb"
require_relative "../../models/following.rb"
require_relative "../../models/like.rb"

RSpec.describe Following, :type => :model do

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

      4.times do |i|
        Following.create(
          id: i + 1,
          star_id: i + 2,
          fan_id: i + 3
        )
      end

    end

    it 'Should report that Harry is following Jill ' do
      jill_user = User.find(2)
      fan_user = jill_user.star_followings[0].fan.username
      expect(fan_user).to eq("Harry")
    end

    it 'Should report that Steven is following Amanda' do
      amanda_user = User.find(4)
      fan_user = amanda_user.star_followings[0].fan.username
      expect(fan_user).to eq("Steven")

    end
  end
end