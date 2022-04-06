# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_02_12_225106) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "followings", force: :cascade do |t|
    t.integer "star_id"
    t.integer "fan_id"
  end

  create_table "hashtags", force: :cascade do |t|
    t.string "text"
  end

  create_table "likes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "tweet_id"
  end

  create_table "mentions", force: :cascade do |t|
    t.integer "tweet_id"
    t.integer "user_id"
  end

  create_table "retweets", force: :cascade do |t|
    t.integer "user_id"
    t.integer "tweet_id"
  end

  create_table "tweethashmappings", force: :cascade do |t|
    t.integer "tweet_id"
    t.integer "hashtag_id"
  end

  create_table "tweetmentionmappings", force: :cascade do |t|
    t.integer "tweet_id"
    t.integer "mention_id"
  end

  create_table "tweets", force: :cascade do |t|
    t.string "text"
    t.integer "user_id"
    t.integer "tweet_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "display_name"
    t.string "email"
    t.string "password"
    t.boolean "active"
  end

  add_foreign_key "likes", "tweets"
  add_foreign_key "likes", "users"
  add_foreign_key "mentions", "tweets"
  add_foreign_key "mentions", "users"
  add_foreign_key "retweets", "tweets"
  add_foreign_key "retweets", "users"
  add_foreign_key "tweets", "tweets"
  add_foreign_key "tweets", "users"
end
