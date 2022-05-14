class BlockedUser
  include Mongoid::Document
  include Mongoid::Timestamps

  field :twitter_handle, type: String
  field :twitter_uid, type: String
  field :twitter_name, type: String
  field :twitter_avatar_url, type: String

  has_and_belongs_to_many :users, class_name: "User", inverse_of: :blocked_users
end
