# class AddForeignKeys < ActiveRecord::Migration[7.0]
#   def change
#     add_foreign_key :tweet_hash_mappings, :tweets, column: :tweet_id, primary_key: "id", if_not_exists: true
#     add_foreign_key :tweet_hash_mappings, :hashtags, column: :hashtag_id, primary_key: "id", if_not_exists: true

#     add_foreign_key :mentions, :tweets, column: :tweet_id, primary_key: "id", if_not_exists: true
#     add_foreign_key :mentions, :users, column: :user_id, primary_key: "id", if_not_exists: true
#     add_foreign_key :retweets, :tweets, column: :tweet_id, primary_key: "id", if_not_exists: true
#     add_foreign_key :retweets, :users, column: :user_id, primary_key: "id", if_not_exists: true
    
#     add_foreign_key :followings, :users, column: :star, primary_key: "id", if_not_exists: true
#     add_foreign_key :followings, :users, column: :fan, primary_key: "id", if_not_exists: true

#     add_foreign_key :tweets, :tweets, column: :tweet_id, primary_key: "id", if_not_exists: true
#     add_foreign_key :tweets, :users, column: :user_id, primary_key: "id", if_not_exists: true
#     add_foreign_key :likes, :tweets, column: :tweet_id, primary_key: "id", if_not_exists: true
#     add_foreign_key :likes, :users, column:  :user_id, primary_key: "id", if_not_exists: true
#   end
# end

   
class AddForeignKeys < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :tweets, :users
    add_foreign_key :tweets,:tweets
    add_foreign_key :mentions,:tweets
    add_foreign_key :mentions,:users
    add_foreign_key :likes, :users
    add_foreign_key :likes,:tweets
    add_foreign_key :retweets,:users
    add_foreign_key :retweets,:tweets
  end
end
