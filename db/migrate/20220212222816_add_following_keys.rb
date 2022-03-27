class AddFollowingKeys < ActiveRecord::Migration[7.0]
  def change
    drop_table :followings

    create_table :followings do |t|
      t.integer :star, foreign_key: true
      t.integer :fan, foreign_key: true
    end
  end
end
