ENV['APP_ENV'] = 'test'
require_relative '../app.rb'
require 'minitest/autorun'
require 'rack/test'

include Rack::Test::Methods

def app
  Sinatra::Application
end

describe "POST on /signup" do
  it "Should create a user" do
    post '/signup', {
      username: "manzi",
      display_name: "@helloWorld",
      email: "manzi@gmail.com",
      password: "lotus"}.to_json
    last_response.ok?
    message = JSON.parse(last_response.body)
    assert_equal("Insert successful.",message) 
  end
end

describe "GET on /:username" do
  it "Should return user info" do
    get '/manzi' #calling the route
    #assert last_response.ok?
    message = JSON.parse(last_response.body)
    puts message
  end

end