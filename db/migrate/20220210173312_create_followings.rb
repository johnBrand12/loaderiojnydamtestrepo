class CreateFollowings < ActiveRecord::Migration[7.0]
  def change
    create_table :followings do |t|
      t.integer :star
      t.integer :fan
    end
  end
end
