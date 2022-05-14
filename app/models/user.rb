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

  protected

  def add_to_repository
    UserRepository.add_username(self.twitter_handle)
  end
end
