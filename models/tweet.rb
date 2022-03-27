class Tweet < ActiveRecord::Base
    has_many :likes, :dependent => :delete_all
    has_many :mentions, :dependent => :delete_all
    has_many :retweets, :dependent => :delete_all

    
    has_many :tweethashmappings, :dependent => :delete_all
    has_many :hashtags, through: :tweethashmappings

    has_many :tweetmentionmappings,:dependent => :delete_all
    has_many :mentions, through: :tweetmentionmappings

    belongs_to :user

    belongs_to :tweet #in case the tweet is a reply, we can access the parent tweet
    has_many :tweets
    
    validates :user_id, presence: true
    validates :text, presence: true, length: { maximum: 280 }
    


    default_scope -> { order(created_at: :desc) }

    def corrupted? 
        if self.text != nil && self.user_id != nil
            false
        else
            true
        end
    end
end