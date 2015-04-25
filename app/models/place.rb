class Place < ActiveRecord::Base
  validates :name, :description, { presence: true }
  validates :description, length: { maximum: 400 }

  belongs_to :user

  mount_uploader :image, PlaceImageUploader
end
