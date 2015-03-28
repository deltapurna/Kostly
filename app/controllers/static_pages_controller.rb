class StaticPagesController < ApplicationController
  def home
    @places = Place.order(updated_at: :desc).limit(8)
  end

  def about
  end
end
