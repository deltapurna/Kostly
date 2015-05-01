class AddGeolocationFieldsToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :address, :string
    add_column :places, :latitude, :float
    add_column :places, :longitude, :float
  end
end
