class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable
  devise :omniauthable, omniauth_providers: [:twitter]

  ## Database authenticatable
  field :email,              type: String, default: ""
  field :password,          type: String
  field :encrypted_password, type: String, default: ""
  ## Rememberable
  field :remember_created_at, type: Time

  ## Twitter
  field :twitter_handle, type: String
  field :twitter_token, type: String
  field :twitter_access_token, type: String
  field :twitter_access_token_secret, type: String
  field :twitter_uid, type: String
  field :twitter_name, type: String
  field :twitter_avatar_url, type: String

  include Mongoid::Timestamps

  has_and_belongs_to_many :blocked_users, class_name: "BlockedUser", inverse_of: :users, autosave: true

  after_create :add_to_repository

  def self.from_omniauth(auth)
    logger.info auth
    where(twitter_uid: auth.uid).first_or_create do |user|
    user.email = auth.info.email || "#{auth.uid}@blockparty.io"
    user.password = Devise.friendly_token[0, 20]
    user.twitter_name = auth.info.name # assuming the user model has a name
    user.twitter_handle = auth.info.nickname # assuming the user model has a username
    user.twitter_avatar_url = auth.info.image # assuming the user model has an image
    user.twitter_access_token = auth.credentials.token
    user.twitter_access_token_secret = auth.credentials.secret
    #user.image = auth.info.image # assuming the user model has an image
    # If you are using confirmable and the provider(s) you use validate emails,
    # uncomment the line below to skip the confirmation emails.
    # user.skip_confirmation!
    end
  end

  def will_save_change_to_email?
    false
  end

  def add_blocked_user(user_attributes)
    blocked = BlockedUser.where(twitter_uid: user_attributes[:id]).first_or_create do |blocked_user|
      blocked_user.twitter_handle =  user_attributes[:screen_name]
      blocked_user.twitter_name = user_attributes[:name]
      blocked_user.twitter_avatar_url= user_attributes[:profile_image_url]
    end
    self.blocked_users << blocked
    self.save
  end

  def update_blocked_users!
    GetBlockedUsersJob.perform_async(self.id.to_s)
  end

  def get_blocked_users(cursor = nil)
    twitter.blocked(cursor)
  end

  def tweet(message)
    twitter.update(message)
  end
  protected

  def twitter
    @twitter ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.credentials.fetch(:twitter_api_token)
      config.consumer_secret     = Rails.application.credentials.fetch(:twitter_api_secret)
      config.access_token        = self.twitter_access_token
      config.access_token_secret = self.twitter_access_token_secret
    end
  end

  def add_to_repository
    UserRepository.add_username(self.twitter_handle)
  end
end
