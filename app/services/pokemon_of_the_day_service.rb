require "httparty"

class PokemonOfTheDayService
  include HTTParty

  base_uri "https://pokeapi.co/api/v2"

  Pokemon = Struct.new(
    :id,
    :name,
    :image_url,
    :types,
    :height_meters,
    :weight_kg,
    :base_experience,
    :stats,
    keyword_init: true
  )

  attr_reader :error_message

  def initialize(date: Date.current)
    @date = date
    @error_message = nil
  end

  def call
    total_pokemon = fetch_total_pokemon_count
    featured_id = featured_pokemon_id(total_pokemon)
    pokemon_data = fetch_pokemon(featured_id)

    Pokemon.new(
      id: pokemon_data.fetch("id"),
      name: titleize_api_name(pokemon_data.fetch("name")),
      image_url: pokemon_image_url(pokemon_data),
      types: pokemon_data.fetch("types").map { |entry| titleize_api_name(entry.fetch("type").fetch("name")) },
      height_meters: pokemon_data.fetch("height").to_f / 10,
      weight_kg: pokemon_data.fetch("weight").to_f / 10,
      base_experience: pokemon_data["base_experience"],
      stats: extract_basic_stats(pokemon_data.fetch("stats"))
    )
  rescue StandardError => e
    Rails.logger.warn("PokemonOfTheDayService failed: #{e.class} - #{e.message}")
    @error_message = "We could not load today's featured Pokemon from PokeAPI right now. Please try again shortly."
    nil
  end

  private

  def fetch_total_pokemon_count
    response = self.class.get("/pokemon?limit=1", timeout: 5)
    raise "PokeAPI count request failed" unless response.success?

    response.fetch("count")
  end

  def featured_pokemon_id(total_pokemon)
    # Turn today's date into a repeatable integer, then keep it inside the API's range.
    seed = @date.strftime("%Y%m%d").to_i
    (seed % total_pokemon) + 1
  end

  def fetch_pokemon(id)
    response = self.class.get("/pokemon/#{id}", timeout: 5)
    return response.parsed_response if response.success?

    Rails.logger.warn(
      "PokeAPI pokemon lookup failed: status=#{response.code} body=#{response.body.to_s.tr("\n", " ")[0, 160]}"
    )
    raise "PokeAPI pokemon request failed"

  end

  def pokemon_image_url(pokemon_data)
    pokemon_data.dig("sprites", "other", "official-artwork", "front_default") ||
      pokemon_data.dig("sprites", "front_default")
  end

  def extract_basic_stats(stats)
    wanted_stats = %w[hp attack defense]

    stats.each_with_object({}) do |stat, summary|
      stat_name = stat.dig("stat", "name")
      next unless wanted_stats.include?(stat_name)

      summary[stat_name.to_sym] = stat.fetch("base_stat")
    end
  end

  def titleize_api_name(value)
    value.to_s.split("-").map(&:capitalize).join(" ")
  end
end
