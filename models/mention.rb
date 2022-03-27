class Mention < ActiveRecord::Base
    has_many :tweetmentionmappings,:dependent => :delete_all
    has_many :tweets, through: :tweetmentionmappings
end