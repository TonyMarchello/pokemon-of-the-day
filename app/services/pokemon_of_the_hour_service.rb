class PokemonOfTheHourService < PokemonFeatureService
  private

  def feature_seed
    @reference_time.strftime("%Y%m%d%H").to_i
  end

  def error_message_text
    "We could not load this hour's featured Pokemon from PokeAPI right now. Please try again shortly."
  end
end
