# frozen_string_literal: true

require "rails"
require "decidim/core"
require "health_check" if Decidim::Pokecode.health_check_enabled
require "rails_semantic_logger" if Decidim::Pokecode.semantic_logger_enabled
require "sidekiq"
require "sidekiq-cron"

module Decidim
  module Pokecode
    # This is the engine that runs on the public interface of Pokecode.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Pokecode

      routes do
        # Add engine routes here
        # resources :pokecode
        # root to: "pokecode#index"
      end

      initializer "pokecode.health_check" do
        if defined?(HealthCheck)
          if (additional = ENV.fetch("HEALTHCHECK_ADDITIONAL_CHECKS", nil))
            HealthCheck.setup do |config|
              config.standard_checks += additional.split
            end
          end

          if (exclude = ENV.fetch("HEALTHCHECK_EXCLUDE_CHECKS", "emailconf"))
            HealthCheck.setup do |config|
              config.standard_checks -= exclude.split
            end
          end
        end
      end

      initializer "pokecode.logger" do
        if ENV["RAILS_LOG_TO_STDOUT"].present?
          if defined?(SemanticLogger) && Rails.env.production?
            $stdout.sync = true
            config.rails_semantic_logger.add_file_appender = false
            config.semantic_logger.add_appender(io: $stdout, formatter: config.rails_semantic_logger.format)
          else
            logger = ActiveSupport::Logger.new($stdout)
            logger.formatter = config.log_formatter
            config.logger = ActiveSupport::TaggedLogging.new(logger)
          end
        end
      end

      initializer "pokecode.shakapacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
