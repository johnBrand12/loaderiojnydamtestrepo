require 'bcrypt'    
class User < ActiveRecord::Base
    include BCrypt
    has_many :tweets, :dependent => :delete_all
    has_many :likes, :dependent => :delete_all
    has_many :retweets, :dependent => :delete_all

    has_many :star_followings, foreign_key: :star_id, class_name: "Following",:dependent => :delete_all
    has_many :stars, through: :star_followings

    has_many :fan_followings, foreign_key: :fan_id, class_name: "Following",:dependent => :delete_all
    has_many :fans, through: :fan_followings


    validates :username, presence: true, length: { maximum: 50 }
    validates :display_name, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
    format: { with: VALID_EMAIL_REGEX },
    uniqueness: true
   
   

    include BCrypt
    #attr_reader :name
  
    def self.authenticate(params = {})
      #puts  params
      return nil if params[:username].blank? || params[:password].blank?
  
      # #<GET USERNAME AND PASSWORD FROM DATABASE HERE>
      #user_name = "@#{params[:username]}"
      userInfo = User.find_by(username:params[:username]) 
      #puts userInfo[:password]

      if (userInfo)
        user_password = userInfo[:password]
        user_name = userInfo[:username]

        username = params[:username].downcase
        return nil if username != user_name
    
        password_hash = Password.new(user_password)
        User.new(username: username) if password_hash  == params[:password] # The password param gets hashed for us by ==
      else
        return nil
      end
    end


    def liked? (tweet) 
      self.likes.to_a.intersection(tweet.likes.to_a).size > 0
    end

    def retweeted? (tweet)
      self.retweets.to_a.intersection(tweet.retweets.to_a).size > 0
    end

    def corrupted?
      #check the follows
      #check the tweets
      self.fan_followings.each do |follow| 
        #check if star user has cur user in star followings
        star = follow.star
        if star.star_followings.to_a.intersection(self.fan_followings.to_a).size == 0
          puts "CORRUPTED!"
          return true
        else
          puts "not corrupted yet"
        end
      
      end
      false
    end
end