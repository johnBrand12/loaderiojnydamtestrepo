require_relative './user.rb'
class Following < ActiveRecord::Base
    belongs_to :star, class_name: "User"
    belongs_to :fan, class_name: "User"

    def fan 
        User.find(self.fan_id)  
    end

    def star
        User.find(self.star_id)
    end
end