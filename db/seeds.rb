require "bcrypt"
require 'csv'

Tweet.delete_all()
Following.delete_all()
User.delete_all()

User.create(
    username: "testuser",
    display_name: "testuser",
    active: true,
    email: "testuser@gmail.com",
    password: BCrypt::Password.create("password")
)


User.find_by_sql("SELECT setval('users_id_seq', (SELECT max(id) FROM users));")
Tweet.find_by_sql("SELECT setval('tweets_id_seq', (SELECT max(id) FROM tweets));")
Following.find_by_sql("SELECT setval('followings_id_seq', (SELECT max(id) FROM followings));")



