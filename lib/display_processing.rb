module Sinatra 
    module DisplayProcessing

        def handle_mention_hashtag_parsing(raw_tweet)


          puts "This is a test to see if hashtags work"
          puts "The raw tweet is #{raw_tweet}"

          word_array = raw_tweet.split

          new_string = ""

          word_array.each do |word|

            localAddition = ""

            if (word.include? "@")

                localAddition = "<span class=\"purple-text\">#{word}</span>"

            elsif (word.include? "#")

                localAddition = "<span class=\"orange-text\">#{word}</span>"

            else

                localAddition = word
            end

            new_string += "#{localAddition} "
          end

          return new_string

        end
    end
  end
  