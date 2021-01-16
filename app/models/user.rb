class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :comments,   dependent: :destroy
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  has_many :favorite_relationships, dependent: :destroy
  has_many :likes, through: :favorite_relationships, source: :micropost
  has_many :active_notifications,  class_name: 'Notification',  foreign_key: 'visiter_id', dependent: :destroy
  has_many :passive_notifications, class_name: 'Notification',  foreign_key: 'visited_id', dependent: :destroy
  has_many :sns_credentials, dependent: :destroy
  validates :name,  presence: true, length: { maximum: 50 }
  validates :username,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence:   true, length: { maximum: 255 },
                    format:     { with: VALID_EMAIL_REGEX },
                    uniqueness: true
  validates :password, presence: true, confirmation: true, length: { minimum: 6 }, allow_nil: true
  validates :password_confirmation, presence: true, allow_nil: true
  validates :profile, length: { maximum: 255 }, allow_blank: true
  
  VALID_PHONE_NUMBER = /\A(((0(\d{1}[-(]?\d{4}|\d{2}[-(]?\d{3}|\d{3}[-(]?\d{2}|\d{4}[-(]?\d{1}|[5789]0[-(]?\d{4})[-)]?)|\d{1,4}\-?)\d{4}|0120[-(]?\d{3}[-)]?\d{3})\z/
  validates :phone, format: { with: VALID_PHONE_NUMBER }, allow_blank: true 
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,:confirmable,
         :omniauthable, omniauth_providers: [:facebook]
  
  def downcase_email
    self.email = email.downcase
  end
  
  def remember_me
    true
  end
         
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
         
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end
  
  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  def following?(other_user)
    following.include?(other_user)
  end
  
  def self.search(search)
    if search
      where(['username LIKE ?', "%#{search}%"])
    else
      all
    end
  end
  
  def like(micropost)
    likes << micropost
  end
  
  def unlike(micropost)
    favorite_relationships.find_by(micropost_id: micropost.id).destroy
  end
  
  def likes?(micropost)
    likes.include?(micropost)
  end
  
  def create_notification_follow!(current_user)
    temp = Notification.where(["visiter_id = ? and visited_id = ? and action = ? ",current_user.id, id, 'follow'])
    if temp.blank?
      notification = current_user.active_notifications.new(
        visited_id: id,
        action: 'follow'
      )
      notification.save if notification.valid?
    end
  end
  
  def self.without_sns_data(auth)
    user = User.where(email: auth.info.email).first
      if user.present?
        sns = SnsCredential.create(
          uid:      auth.uid,
          provider: auth.provider,
          user_id:  user.id
        )
      else
        user = User.new(
          name:     auth.info.name,
          username: auth.info.name,
          email:    auth.info.email,
          password: Devise.friendly_token[0, 20]
        )
        sns = SnsCredential.new(
          uid: auth.uid,
          provider: auth.provider
        )
      end
      return { user: user ,sns: sns}
  end

  def self.with_sns_data(auth, snscredential)
    user = User.where(id: snscredential.user_id).first
    unless user.present?
      user = User.new(
        name:     auth.info.name,
        username: auth.info.name,
        email:    auth.info.email,
        password: Devise.friendly_token[0, 20]
      )
    end
    return {user: user}
  end

  def self.find_oauth(auth)
    uid = auth.uid
    provider = auth.provider
    snscredential = SnsCredential.where(uid: uid, provider: provider).first
    if snscredential.present?
      user = with_sns_data(auth, snscredential)[:user]
      sns = snscredential
    else
      user = without_sns_data(auth)[:user]
      sns = without_sns_data(auth)[:sns]
    end
    return { user: user ,sns: sns}
  end
  
end