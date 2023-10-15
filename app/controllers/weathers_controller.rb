class WeathersController < ApplicationController

  def index; end

  def show
    zip_code = params[:zip_code]
    @forecast = get_weather(zip_code)
  end

  private

  def get_weather(zip_code)
    WeatherApiService.new.get_weather_by_zip(zip_code)
  end
end
