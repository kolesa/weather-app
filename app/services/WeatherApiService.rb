class WeatherApiService
  def initialize
    @api_key = ENV['WEATHER_API_KEY']
    @client = OpenWeather::Client.new( api_key: @api_key )
  end

  def get_weather_by_zip(zip_code)
    @client.current_weather( zip: zip_code )
  end
end
