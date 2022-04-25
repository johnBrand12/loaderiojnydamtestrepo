ENV['APP_ENV'] = 'test'

require_relative '../app.rb'
require 'rack/test'
require 'test/spec'


require_relative "../models/tweet.rb"
require_relative "../models/user.rb"
require_relative "../models/mention.rb"
require_relative "../models/following.rb"
require_relative "../models/like.rb"
require_relative "../models/retweet.rb"

db_options = {adapter: 'postgresql', database: 'nanotwitter_test'}
ActiveRecord::Base.establish_connection(db_options)

RSpec.describe "Testing the GET /following via the /followingjsontest route and GET /follower via the /followerjsontest route" do

  include Rack::Test::Methods

  def app
    SimpleApp
  end

  before(:all) do

    redis_test_obj = Redis.new(url: 'redis://redistogo:1af524c39770f9e227ef0f94a3e6ac94@sole.redistogo.com:10663/')
    redis_test_obj.flushall

    Retweet.delete_all()
    Tweet.delete_all()
    Following.delete_all()
    User.delete_all()

    User.create!(
      id: 1,
      username: "testfanuserone",
      display_name: "Test Fan User One",
      active: true,
      email: "testfanuserone@gmail.com",
      password: BCrypt::Password.create("password")
    )

    User.create!(
      id: 2,
      username: "teststaruserone",
      display_name: "Test Star User One",
      active: true,
      email: "teststaruserone@gmail.com",
      password: BCrypt::Password.create("password")
    )

    User.create!(
      id: 3,
      username: "teststarusertwo",
      display_name: "Test Star User Two",
      active: true,
      email: "teststarusertwo@gmail.com",
      password: BCrypt::Password.create("password")
    )

    Following.create!(
        id: 1,
        star_id: 2,
        fan_id: 1
    )

    Following.create!(
      id: 2,
      star_id: 3,
      fan_id: 1
    )

  end

  it 'should return a json representation of the following list with the correct configuration' do

    get '/followingsjsontest?user_id=1'
    attributes = JSON.parse(last_response.body)
    expect(attributes[0]["star_id"]).to eq(2)
    expect(attributes[1]["star_id"]).to eq(3)

  end

  it 'should return a json representation of the follower list with the correct configuration' do

    get '/followersjsontest?user_id=3'
    attributes = JSON.parse(last_response.body)
    expect(attributes[0]["fan_id"]).to eq(1)
    
  end

end



RSpec.describe "POST on /updatefollowings/:fan_id/:star_id/:action" do


  include Rack::Test::Methods

  def app
    SimpleApp
  end


  before(:all) do

    redis_test_obj = Redis.new(url: 'redis://redistogo:1af524c39770f9e227ef0f94a3e6ac94@sole.redistogo.com:10663/')
    redis_test_obj.flushall

    Retweet.delete_all()
    Tweet.delete_all()
    Following.delete_all()
    User.delete_all()

    User.create!(
      id: 1,
      username: "testfanuserone",
      display_name: "Test Fan User One",
      active: true,
      email: "testfanuserone@gmail.com",
      password: BCrypt::Password.create("password")
    )

    User.create!(
      id: 2,
      username: "teststaruserone",
      display_name: "Test Star User One",
      active: true,
      email: "teststaruserone@gmail.com",
      password: BCrypt::Password.create("password")
    )
    
    Following.create!(
      id: 1,
      star_id: 2,
      fan_id: 1
    )

  end

  it 'Should remove the following object from the database' do

    post '/updatefollowings/1/2/unfollow?user_id=1'
    expect(last_response.status).to eq(200)
    following_list = Following.all
    expect(following_list.count).to eq(0)

  end



  ## more tests to handle edge cases


end

RSpec.describe "POST on /insertfollowingservice", type: :request do


  include Rack::Test::Methods

  def app
    SimpleApp
  end

  before(:all) do

    redis_test_obj = Redis.new(url: 'redis://redistogo:1af524c39770f9e227ef0f94a3e6ac94@sole.redistogo.com:10663/')
    redis_test_obj.flushall

    Retweet.delete_all()
    Tweet.delete_all()
    Following.delete_all()
    User.delete_all()

    User.create!(
      id: 1,
      username: "testfanuserone",
      display_name: "Test Fan User One",
      active: true,
      email: "testfanuserone@gmail.com",
      password: BCrypt::Password.create("password")
    )

    User.create!(
      id: 2,
      username: "teststaruserone",
      display_name: "Test Star User One",
      active: true,
      email: "teststaruserone@gmail.com",
      password: BCrypt::Password.create("password")
    )
  end

  it "should insert a new following object into the database" do

    post '/insertfollowingservice?user_id=1', {
      star_id: 2
    }.to_json

    expect(last_response.status).to eq(200)
    following_obj = Following.where(fan_id: 1)
    expect(following_obj.length).to eq(1)

  end


  # more tests to handle edge cases....


end

RSpec.describe "GET on /following/retrievelistcache", type: :request do

  include Rack::Test::Methods

  def app
    SimpleApp
  end
  

  before(:all) do

    redis_test_obj = Redis.new(url: 'redis://redistogo:1af524c39770f9e227ef0f94a3e6ac94@sole.redistogo.com:10663/')
    redis_test_obj.flushall

    Retweet.delete_all()
    Tweet.delete_all()
    Following.delete_all()
    User.delete_all()

    User.create!(
      id: 1,
      username: "testfanuserone",
      display_name: "Test Fan User One",
      active: true,
      email: "testfanuserone@gmail.com",
      password: BCrypt::Password.create("password")
    )

    User.create!(
      id: 2,
      username: "teststaruserone",
      display_name: "Test Star User One",
      active: true,
      email: "teststaruserone@gmail.com",
      password: BCrypt::Password.create("password")
    )

    User.create!(
      id: 3,
      username: "teststarusertwo",
      display_name: "Test Star User Two",
      active: true,
      email: "teststarusertwo@gmail.com",
      password: BCrypt::Password.create("password")
    )


    Following.create!(
        id: 1,
        star_id: 2,
        fan_id: 1
    )

    Following.create!(
      id: 2,
      star_id: 3,
      fan_id: 1
    )

  end

  it "should return a list of json which represents that user id 1 has 2 followings" do

    get '/following/retrievelistcache?uid=1&user_id=1'
    expect(last_response.status).to eq(200)
    attributes = JSON.parse(last_response.body)
    expect(attributes.length).to eq(2)
    expect(attributes[0]["star_id"]).to eq(2)
    expect(attributes[1]["star_id"]).to eq(3)

  end

  ## more tests to handle edge cases


end



