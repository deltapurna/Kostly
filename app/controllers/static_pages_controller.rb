class StaticPagesController < ApplicationController
  before_action :age

  def home
    @name = params[:name]
    render 'home2'
  end

  def about
  end

  def age
    @age = params[:age]
  end
end
