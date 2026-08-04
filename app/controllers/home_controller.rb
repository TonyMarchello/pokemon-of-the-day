class HomeController < ApplicationController
  def index
    @featured_date = Date.current
    service = PokemonOfTheDayService.new(date: @featured_date)
    @featured_pokemon = service.call
    @error_message = service.error_message
  end
end

