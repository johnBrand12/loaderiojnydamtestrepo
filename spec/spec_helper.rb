ENV['RACK_ENV'] = 'test'
require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end 
end