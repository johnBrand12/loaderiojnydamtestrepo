class Tweetmentionmapping < ActiveRecord::Base
    belongs_to :tweet
    belongs_to :mention
end