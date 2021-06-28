require_relative 'boot'

require 'rails/all'
require 'mime/types'
require 'clamav'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Deco
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.action_view.automatically_disable_submit_tag = false
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.encoding = "utf-8"

    config.i18n.default_locale = :ja
    config.autoload_paths += %W(#{config.root}/lib)
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    # RailsEngine用のassets定義
    Dir.glob("vendor/engines/*/").each do |path|
      config.assets.precompile += %W( #{File.basename(path)}/application.* )
    end
  end
end
