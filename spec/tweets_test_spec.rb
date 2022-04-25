ENV['APP_ENV'] = 'test'

require_relative '../app.rb'
require 'rack/test'
require 'faker'

require 'test/spec'
require 'rspec/core'

def app
  SimpleApp
end

include Test::Unit::Assertions
include Rack::Test::Methods

describe 'like tweet' do 
  before do 

    Like.delete_all
    Tweet.delete_all
    User.delete_all

    User.create(display_name:"jasmyne",username:"jasmynej",password:"password",email:"jasmynej14@gmail.com")
    Tweet.create(user_id:User.first.id,text:"tweet text")
    Like.create(user_id:User.first.id,tweet_id:Tweet.first.id)
  end

  it "should say first user likes tweet" do 
    
    assert_equal(true,User.first.liked?(Tweet.first))
  end
  

end

describe 'retweet tweet' do 
  before do 

    Like.delete_all
    Retweet.delete_all
    Tweet.delete_all
    User.delete_all
    User.create(display_name:"jasmyne",username:"jasmynej",password:"password",email:"jasmynej14@gmail.com")
    Tweet.create(user_id:User.first.id,text:"tweet text")
    Retweet.create(user_id:User.first.id,tweet_id:Tweet.first.id)
  end

  it 'should say first user retweeted tweet' do
  
  assert_equal(true,User.first.retweeted?(Tweet.first))
  end
end