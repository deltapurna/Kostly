class StaticPagesController < ApplicationController
  before_action :set_age

  def home
    @name = params[:name]
  end

  def about
  end

  private

    def set_age
      @age = params[:age]
    end
end
