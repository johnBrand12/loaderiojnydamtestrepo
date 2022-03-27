ENV['APP_ENV'] = 'test'
require_relative '../app.rb'

require 'rack/test'
require 'test/spec'
require 'rspec/core'


def app
  Sinatra::Application
end

include Test::Unit::Assertions
include Rack::Test::Methods

#This is the following - this is testing for the people that I follow
#This is testing the list of people that I follow, so the fan_id = 115
describe "GET on /updatefollowing/:fanfollowing" do
  before do
    Following.delete_all()
    Following.create(
      id: 92,
      star_id: 6,
      fan_id: 115,
      fan_active: true)
    
    Following.create(
        id: 135,
        star_id: 30,
        fan_id: 115,
        fan_active: false)
  end
  it "should change following from true to false for a user" do
    #This is testing for a star_id = 6
    #This just means that the fan_id = 115 and star_id = 6(sample user). Therefore user 115 is following user 6
    get '/updatefollowing/92' 
    following = Following.where(fan_id: 115).find_by(star_id: 6)
    assert_equal(false,following.fan_active)
  end

  #The opposite from above  
  it "should change following from false to true for a user" do
    get '/updatefollowing/135'
    followings = Following.where(fan_id: 115).find_by(star_id: 30)
    assert_equal(true,followings.fan_active)
  end
end

#This is for the list of people who follow this user. Therefore, star_id = 115
describe "GET on /updatefollowers/:fanfollowing" do
  before do

    Following.delete_all()
    Following.create(
      id: 10001,
      star_id: 37,
      fan_id: 115,
      fan_active: false)
   
    Following.create(
        id: 91,
        star_id: 47,
        fan_id: 115,
        fan_active: true)
    
  end
  it "should change fan_active for this user." do
    #Calling the route with star_id = 37
    #When the code executes, the fan_active should be true for 37 signifying that
    #this user 37 is now a follower of user 115
    get '/updatefollowers/10001' #calling the route
    followings = Following.where(fan_id: 115).find_by(star_id: 37)
    assert_equal(true,followings.fan_active)
  end

  it "should change fan_active for this user." do
    #Calling the route with star_id = 47
    #When the code executes, the fan_active should be false for 37 signifying that
    #this user 37 is no longer a follower of user 115
    get '/updatefollowers/91' #calling the route
    followings = Following.where(fan_id: 115).find_by(star_id: 47)
    assert_equal(false,followings.fan_active)
  end


end
#This should add another record to the table where the starid = 26 and the fanid = 115
describe "GET on /insertfollowing" do
    it "should add another record to the followings table" do
      num = Following.where(fan_id: 115).count
        get '/insertfollowing?starid=20&fanid=115'
        assert_equal(num+1,Following.where(fan_id: 115).count) #asserting that there are 8 records in the table
        following1 = Following.where(fan_id: 115).find_by(star_id: 20) #getting this following record
        assert_equal(true,following1.fan_active) #asserting that the fan_active is true 
    end
end 