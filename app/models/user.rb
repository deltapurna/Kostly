class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name, :email, presence: true, length: { maximum: 255 }
  validates :email, uniqueness: true, format: { with: VALID_EMAIL_REGEX }

  has_many :places, dependent: :destroy
end
