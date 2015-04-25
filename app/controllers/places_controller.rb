class PlacesController < ApplicationController
  before_action :authorize, except: [:index, :show]
  before_action :authorize_owner, only: [:edit, :update, :destroy]

  def index
    @places = Place.page(params[:page]).per(5)
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

    if @place.update(place_params)
      redirect_to places_url, notice: 'Place updated!'
    else
      render :edit
    end
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
