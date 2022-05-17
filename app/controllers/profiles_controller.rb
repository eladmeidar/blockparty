class ProfilesController < ApplicationController

    before_action :authenticate_user!

    def show
        @user = User.where(twitter_handle: params[:id]).first
        if @user.blank?
            redirect_to root_url
        end
    end
end
