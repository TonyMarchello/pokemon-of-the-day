class HomeController < ApplicationController
  def index
    @reference_time = Time.current
    @featured_date = @reference_time.to_date

    day_service = PokemonOfTheDayService.new(reference_time: @reference_time)
    @featured_pokemon = day_service.call
    @featured_error_message = day_service.error_message

    hour_service = PokemonOfTheHourService.new(reference_time: @reference_time)
    @hourly_pokemon = hour_service.call
    @hourly_error_message = hour_service.error_message
  end
end
