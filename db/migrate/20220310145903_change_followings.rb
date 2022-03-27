class ChangeFollowings < ActiveRecord::Migration[7.0]
  def change
    change_table :followings do |t|
      t.boolean :fan_active, :default => true
    end
  end
end
