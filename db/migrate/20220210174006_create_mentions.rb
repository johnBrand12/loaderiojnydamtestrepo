class CreateMentions < ActiveRecord::Migration[7.0]
  def change
    create_table :mentions do |t| 
      t.integer :tweet_id
      t.integer :user_id
    end
  end
end
