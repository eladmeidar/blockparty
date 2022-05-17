class PagesController < ApplicationController

    def home
    end

    def search
        @usernames = UserRepository.search(params[:q])
        @users = User.where(:twitter_handle.in => @usernames[:usernames])
    end
end
