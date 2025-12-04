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
      ".gitignore" => [
        "/app/static/api/docs"
      ],
      "config/sidekiq.yml" => [
        '<%= ENV.fetch("SIDEKIQ_CONCURRENCY", 5) %>'
      ],
      "config/schedule.yml" => [
        'class: "InvokeRakeTaskJob"'
      ],
      "Dockerfile" => [
        "decidim_api:generate_docs"
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
