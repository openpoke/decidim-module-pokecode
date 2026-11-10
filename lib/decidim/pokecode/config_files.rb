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
        "3.4.7"
      ],
      ".github/workflows/dependabot.yml" => [
        "schedule:",
        "weekly"
      ],
      ".gitignore" => [
        "mise.toml",
        "/app/views/static/api"
      ],
      "config/queue.yml" => [
        '<%= ENV.fetch("JOB_CONCURRENCY", 1) %>'
      ],
      "config/recurring.yml" => [
        "clear_solid_queue_finished_jobs",
        "class: InvokeRakeTaskJob"
      ],
      "bin/jobs" => [
        "SolidQueue::Cli.start"
      ],
      "config/puma.rb" => [
        "plugin :solid_queue"
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

    Pokecode.config_files["config/puma.rb"] << "SemanticLogger.reopen" if Pokecode.semantic_logger_enabled
  end
end
