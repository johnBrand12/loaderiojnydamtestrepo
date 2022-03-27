module Sinatra 
  module Authentication
      def authenticate!
        unless session[:user]
          session[:original_request] = request.path_info
          redirect '/'
        end
      end

      def redirect_to_original_request
        user = session[:user]
        original_request = session[:original_request] #original request is nil!!!!!!
        if original_request == nil
            original_request = '/home'
        else
            session[:original_request] = nil
        end
        redirect original_request
      end  
  end
end
