require "httparty"

class PokemonFeatureService
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

  def initialize(reference_time: Time.current)
    @reference_time = reference_time
    @error_message = nil
  end

  def call
    total_pokemon = fetch_total_pokemon_count
    pokemon_data = fetch_pokemon(featured_pokemon_offset(total_pokemon))

    build_pokemon(pokemon_data)
  rescue StandardError => e
    Rails.logger.warn("#{self.class.name} failed: #{e.class} - #{e.message}")
    @error_message = error_message_text
    nil
  end

  private

  def build_pokemon(pokemon_data)
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
  end

  def fetch_total_pokemon_count
    response = self.class.get("/pokemon?limit=1", timeout: 5)
    raise "PokeAPI count request failed" unless response.success?

    response.fetch("count")
  end

  def featured_pokemon_offset(total_pokemon)
    feature_seed % total_pokemon
  end

  def fetch_pokemon(offset)
    response = self.class.get("/pokemon?limit=1&offset=#{offset}", timeout: 5)
    raise "PokeAPI pokemon list request failed" unless response.success?

    pokemon_entry = response.fetch("results").first
    raise "PokeAPI pokemon list was empty" if pokemon_entry.nil?

    Rails.logger.info(
      "#{self.class.name} resolved #{pokemon_entry.fetch('name')} from #{pokemon_entry.fetch('url')}"
    )

    pokemon_response = self.class.get(pokemon_entry.fetch("url"), timeout: 5)
    return pokemon_response.parsed_response if pokemon_response.success?

    Rails.logger.warn(
      "PokeAPI pokemon lookup failed: status=#{pokemon_response.code} body=#{pokemon_response.body.to_s.tr("\n", " ")[0, 160]}"
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

  def error_message_text
    "We could not load the featured Pokemon right now. Please try again shortly."
  end

  def feature_seed
    raise NotImplementedError, "#{self.class.name} must define #feature_seed"
  end
end
