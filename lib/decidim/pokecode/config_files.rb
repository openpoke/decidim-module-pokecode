# frozen_string_literal: true

module Decidim
  module Pokecode
    class << self
      # Returns a hash with the configuration files to be copied to the host application
      # Format:
      #  { "path/to/file" => [ "lines to be checked not to exist" ] }
      attr_accessor :config_files
    end

    Pokecode.config_files = {
      ".ruby-version" => [
        "3.3.10"
      ],
      ".gitignore" => [
        "mise.toml",
        "/app/views/static/api"
      ],
      "config/sidekiq.yml" => [
        '<%= ENV.fetch("SIDEKIQ_CONCURRENCY", 5) %>'
      ],
      "config/schedule.yml" => [
        'class: "InvokeRakeTaskJob"'
      ],
      "config/storage.yml" => [
        "public:",
        "force_path_style:",
        "request_checksum_calculation:"
      ],
      "Dockerfile" => [
        "curl -fsSL https://deb.nodesource.com/setup_22.x",
        "npm install yarn -g",
        "bundle config set --deployment true",
        "bundle config set --local without 'development test'",
        "rm -rf node_modules packages/*/node_modules tmp/* vendor/bundle test spec app/packs .git"
      ]
    }

    Pokecode.config_files["Dockerfile"] << "curl -sS http://localhost:3000/health_check | grep success" if Pokecode.health_check_enabled

    if Pokecode.semantic_logger_enabled
      Pokecode.config_files["config/puma.rb"] = [
        "SemanticLogger.reopen"
      ]
    end
  end
end
