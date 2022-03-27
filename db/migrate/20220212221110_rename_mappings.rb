class RenameMappings < ActiveRecord::Migration[7.0]
  def change
    rename_table :tweethashmapping, :tweethashmappings
    rename_table :tweetmentionmapping, :tweetmentionmappings
  end
end
