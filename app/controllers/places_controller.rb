class PlacesController < ApplicationController
  def index
    @places = Place.all
  end

  def show
    @place = Place.find(params[:id])
  end

  def new
    @place = Place.new
  end

  def create
    @place = current_user.places.build(place_params)

    if @place.save
      redirect_to places_url, notice: 'Place created!'
    else
      render :new
    end
  end

  def edit
    @place = Place.find(params[:id])
  end

  def update
    @place = Place.find(params[:id])

    @place.update(place_params)

    redirect_to places_url, notice: 'Place updated!'
  end

  def destroy
    Place.find(params[:id]).destroy

    redirect_to places_url, notice: 'Place deleted!'
  end

  private

  def place_params
    params.require(:place).permit(:name, :description)
  end
end
