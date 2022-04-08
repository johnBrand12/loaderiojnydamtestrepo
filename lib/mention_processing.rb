module Sinatra 
    module MentionProcessing
      def process_mentions(raw_tweet)
        puts "This is a test to see if hashtags work"
        puts "The raw tweet is #{raw_tweet}"

        # raw_tweet_array = raw_tweet.split

        # rgex = Regexp.new '/#[a-z]+/'

        new_array = raw_tweet.scan(/@[a-z]+/)

        # verification check to make sure mentions are actual people 
        # This loop will return nil if the mention with the associated username doesn't exist
        new_array.each do |mention_instance|

          raw_text = mention_instance[1, mention_instance.length]

          user_result_query = User.where(username: raw_text)

          if (User.where(username: raw_text).count == 0) 
            return nil
          end
        end

        return new_array
      end
    end
  end
  