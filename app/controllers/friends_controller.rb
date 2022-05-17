class FriendsController < ApplicationController

    before_action :authenticate_user!
    before_action :find_user

    def follow
        current_user.follow!(@user)
        render json: { status: 'success' }, status: :created
    end

    def unfollow
        current_user.unfollow!(@user)
        render json: { status: 'success' }, status: :ok
    end

    protected

    def find_user
        @user = User.where(id: params[:id]).first
        if @user.blank?
            render json: { status: 'error', message: 'User not found' }, status: :not_found and return
        end
    end

end
