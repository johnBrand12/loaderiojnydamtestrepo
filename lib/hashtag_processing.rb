module Sinatra 
    module HashTagProcessing
        def process_hashtags(raw_tweet)
          puts "This is a test to see if hashtags work"
          puts "The raw tweet is #{raw_tweet}"

          # raw_tweet_array = raw_tweet.split

          # rgex = Regexp.new '/#[a-z]+/'

          new_array = raw_tweet.scan(/#[a-z]+/)

          return new_array
        end
    end
  end
  