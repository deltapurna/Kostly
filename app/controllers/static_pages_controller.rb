class StaticPagesController < ApplicationController
  def home
    # Grab the 8 last updated places
    # Other query that you might use
    # Grap 8 latest created places => Place.last(8)
    @places = Place.order(updated_at: :desc).limit(8)
    @markers = @places.select{|p| p.latitude.present? && p.longitude.present?}.map{|p| "&markers=#{p.latitude},#{p.longitude}"}.join
  end

  def about
  end
end
