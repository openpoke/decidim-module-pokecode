# frozen_string_literal: true

module Decidim
  module Pokecode
    # This is the engine that runs on the public interface of Pokecode.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Pokecode

      initializer "pokecode.sidekiq" do
        if Decidim::Pokecode.sidekiq_enabled
          Decidim::Core::Engine.routes do
            require "sidekiq/web"
            require "sidekiq/cron/web"
            authenticate :user, ->(u) { u.admin? } do
              mount Sidekiq::Web => "/sidekiq"
            end
          end
          Rails.logger.info "[Decidim::Pokecode] Sidekiq Web UI enabled."
        else
          Rails.logger.info "[Decidim::Pokecode] Sidekiq Web UI disabled."
        end
      end

      initializer "pokecode.health_check_ssl_exclusion", before: :build_middleware_stack do |app|
        if defined?(HealthCheck)
          # Ensure health_check endpoints bypass SSL redirection for Docker/load balancer health checks
          app.config.ssl_options ||= {}
          app.config.ssl_options[:redirect] ||= {}
          app.config.ssl_options[:redirect][:exclude] = ->(request) { request.path =~ /health_check/ }
          Rails.logger.info "[Decidim::Pokecode] SSL exclusion for health_check enabled."
        end
      end

      config.to_prepare do
        if Decidim::Pokecode.assembly_members_visible_enabled
          Decidim::Assembly.include(Decidim::Pokecode::AssemblyOverride)
          Decidim::Assemblies::Permissions.include(Decidim::Pokecode::AssembliesPermissionsOverride)
          Rails.logger.info "[Decidim::Pokecode] Assembly members visibility override enabled."
        else
          Rails.logger.info "[Decidim::Pokecode] Assembly members visibility override disabled."
        end

        if Decidim::Pokecode.analytics_enabled
          Decidim::ApplicationController.include(Decidim::Pokecode::NeedsAnalyticsCspDirectives)
          Rails.logger.info "[Decidim::Pokecode] Analytics override enabled."
        else
          Rails.logger.info "[Decidim::Pokecode] Analytics override disabled."
        end

        if Decidim::Pokecode.active_storage_s3_urls.present?
          Decidim::ApplicationController.include(Decidim::Pokecode::NeedsStorageCspDirectives)
          Rails.logger.info "[Decidim::Pokecode] Active Storage S3 CSP directives override enabled."
        else
          Rails.logger.info "[Decidim::Pokecode] Active Storage S3 CSP directives override disabled."
        end

        if Decidim::Pokecode.aws_cdn_host.present?
          Aws::S3::Object.include(Decidim::Pokecode::S3ObjectOverride)
          Rails.logger.info "[Decidim::Pokecode] Active Storage CDN override enabled."
        else
          Rails.logger.info "[Decidim::Pokecode] Active Storage CDN override disabled."
        end
      end

      initializer "pokecode.zeitwerk_ignore_deface" do
        Rails.autoloaders.main.ignore(Pokecode::Engine.root.join("app/overrides"))
      end

      initializer "pokecode.sentry" do
        if Decidim::Pokecode.sentry_enabled
          Sentry.init do |config|
            config.dsn = Decidim::Pokecode.sentry_dsn
            # get breadcrumbs from logs
            config.breadcrumbs_logger = [:active_support_logger, :http_logger]
            # Add data like request headers and IP for users, if applicable;
            # see https://docs.sentry.io/platforms/ruby/data-management/data-collected/ for more info
            config.send_default_pii = true
          end
          Rails.logger.info "[Decidim::Pokecode] Sentry enabled to DSN #{Decidim::Pokecode.sentry_dsn}."
        else
          Rails.logger.info "[Decidim::Pokecode] Sentry disabled."
        end
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

          Rails.logger.info "[Decidim::Pokecode] HealthCheck enabled."
        else
          Rails.logger.info "[Decidim::Pokecode] HealthCheck disabled."
        end
      end

      initializer "pokecode.deface_enabled" do
        config.deface.enabled = ENV["DB_ADAPTER"].blank? || ENV.fetch("DB_ADAPTER", nil) == "postgresql" if config.respond_to?(:deface)
      end

      initializer "pokecode.logger" do
        if ENV["RAILS_LOG_TO_STDOUT"].present?
          if defined?(SemanticLogger) && Rails.env.production?
            $stdout.sync = true
            config.rails_semantic_logger.add_file_appender = false
            config.semantic_logger.add_appender(io: $stdout, formatter: config.rails_semantic_logger.format)
            Rails.logger.info "[Decidim::Pokecode] SemanticLogger logging to STDOUT enabled."
          else
            logger = ActiveSupport::Logger.new($stdout)
            logger.formatter = config.log_formatter
            config.logger = ActiveSupport::TaggedLogging.new(logger)
            Rails.logger.info "[Decidim::Pokecode] ActiveSupport::Logger logging to STDOUT enabled."
          end
        else
          Rails.logger.info "[Decidim::Pokecode] Logging to STDOUT disabled."
        end
      end

      initializer "pokecode.rack_attack" do
        if Rails.env.production? || Rails.env.test?
          # Provided that trusted users use an HTTP request param named skip_rack_attack
          # with this you can perform apache benchmark test like this:
          # ab -n 2000 -c 20 'https://decidim.url/?skip_rack_attack=some-secret'
          Rack::Attack.safelist("bypass active storage") do |request|
            # skip rails active storage routes
            request.path.start_with?("/rails/active_storage")
          end

          Rack::Attack.safelist("bypass authenticated users") do |request|
            # skip logged users
            request.env.dig("rack.session", "warden.user.user.key").present?
          end

          if Decidim::Pokecode.rack_attack_skip.present?
            Rack::Attack.safelist("bypass with secret param") do |request|
              # Requests are allowed if the return value is truthy
              request.params["skip_rack_attack"] == Decidim::Pokecode.rack_attack_skip
            end
          end

          if Decidim::Pokecode.rack_attack_ips.present?
            Decidim::Pokecode.rack_attack_ips.each do |ip|
              Rack::Attack.safelist_ip(ip)
            end
          end
        end
      end

      initializer "pokecode.shakapacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
