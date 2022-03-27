class RenameStarFanIds < ActiveRecord::Migration[7.0]
  def change
    rename_column :followings, :star, :star_id
    rename_column :followings, :fan, :fan_id
  end
end
