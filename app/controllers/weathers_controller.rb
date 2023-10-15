class WeathersController < ApplicationController
  rescue_from Faraday::ResourceNotFound, with: :zip_not_found

  def index; end

  def show
    zip_code = params[:zip_code]
    if zip_code =~ /^[0-9]{5,}$/
      @forecast = get_weather(zip_code)
    else
      flash[:error] = "Invalid zip code. Please enter a 5-digit or longer numeric zip code."
      redirect_to weathers_path
    end
  end

  private

  def get_weather(zip_code)
    @cached = true
    Rails.cache.fetch("weather_forecast_#{zip_code}", expires_in: 30.minutes) do
      @cached = false
      WeatherApiService.new.get_weather_by_zip(zip_code)
    end
  end

  def zip_not_found
    flash[:error] = "Invalid zip code."
  end
end
