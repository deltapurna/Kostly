class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name, :email, presence: true, length: { maximum: 255 }
  validates :email, uniqueness: true, format: { with: VALID_EMAIL_REGEX }

  has_many :places, dependent: :destroy

  has_secure_password

  def set_reset_password_token
    self.reset_password_token = loop do
      token = SecureRandom.hex
      break token unless self.class.exists?(reset_password_token: token)
    end
    save!
  end
end
