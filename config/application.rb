
require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module SwexeTeam11
  class Application < Rails::Application
    config.load_defaults 8.1

    # 日本時間（JST）を使用
    config.time_zone = "Tokyo"

    # データベースにはUTCで保存
    config.active_record.default_timezone = :utc

    # APIのみではなく通常のRailsアプリとして使用
    config.api_only = false
  end
end
