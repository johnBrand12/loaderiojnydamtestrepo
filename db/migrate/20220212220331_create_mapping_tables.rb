class CreateMappingTables < ActiveRecord::Migration[7.0]
  def change
    create_table :tweethashmapping do |t|
      t.integer :tweet_id
      t.integer :hashtag_id
    end

    create_table :tweetmentionmapping do |t|
      t.integer :tweet_id
      t.integer :mention_id
    end
    
  end
end
