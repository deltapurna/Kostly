class Place < ActiveRecord::Base
  validates :name, :description, { presence: true }
  validates :description, length: { maximum: 400 }

  geocoded_by :address
  after_validation :geocode

  belongs_to :user

  mount_uploader :image, PlaceImageUploader
end
