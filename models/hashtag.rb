class Hashtag < ActiveRecord::Base
    has_many :tweethashmappings
    has_many :tweets, through: :tweethashmappings
end
