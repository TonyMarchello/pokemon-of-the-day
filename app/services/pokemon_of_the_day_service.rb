class PokemonOfTheDayService < PokemonFeatureService
  private

  def feature_seed
    @reference_time.to_date.strftime("%Y%m%d").to_i
  end

  def error_message_text
    "We could not load today's featured Pokemon from PokeAPI right now. Please try again shortly."
  end
end
