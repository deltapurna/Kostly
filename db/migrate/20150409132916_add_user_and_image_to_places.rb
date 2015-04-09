class AddUserAndImageToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :user_id, :integer
    add_column :places, :image, :string
  end
end
