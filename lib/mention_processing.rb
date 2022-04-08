module Sinatra 
    module MentionProcessing
        def process_mentions
          unless session[:user]
            session[:original_request] = request.path_info
            redirect '/'
          end
        end
    end
  end
  