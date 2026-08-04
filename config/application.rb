require_relative "boot"

require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "active_support/core_ext/integer/time"

Bundler.require(*Rails.groups)

module PokemonOfTheDay
  class Application < Rails::Application
    config.load_defaults 7.1

    # We only need server-rendered HTML and CSS for this assessment.
    config.time_zone = "UTC"
    config.autoload_paths << Rails.root.join("app/services")
    config.eager_load_paths << Rails.root.join("app/services")
  end
end
