# frozen_string_literal: true

module Decidim
  module Pokecode
    include ActiveSupport::Configurable

    config_accessor :health_check_enabled do
      Decidim::Env.new("DISABLE_HEALTH_CHECK", false).blank?
    end

    config_accessor :semantic_logger_enabled do
      Decidim::Env.new("DISABLE_SEMANTIC_LOGGER", false).blank?
    end

    config_accessor :sidekiq_enabled do
      Decidim::Env.new("DISABLE_SIDEKIQ", false).blank?
    end

    config_accessor :sentry_dsn do
      Decidim::Env.new("SENTRY_DSN", "").value
    end

    config_accessor :admin_iframe_url do
      Decidim::Env.new("ADMIN_IFRAME_URL", "").value
    end

    config_accessor :admin_iframe_title do
      Decidim::Env.new("ADMIN_IFRAME_TITLE", "Web Stats").value
    end

    config_accessor :pokecode_footer_enabled do
      Decidim::Env.new("DISABLE_POKECODE_FOOTER", false).blank?
    end

    config_accessor :language_menu_enabled do
      Decidim::Env.new("DISABLE_LANGUAGE_MENU", false).blank?
    end

    config_accessor :assembly_members_visible_enabled do
      Decidim::Env.new("DISABLE_ASSEMBLY_MEMBERS_VISIBLE", false).blank?
    end

    config_accessor :umami_analytics_id do
      Decidim::Env.new("UMAMI_ANALYTICS_ID", "").value
    end

    config_accessor :umami_analytics_url do
      Decidim::Env.new("UMAMI_ANALYTICS_URL", "https://analytics.pokecode.net/script.js").value
    end

    def self.deface_enabled
      Pokecode.pokecode_footer_enabled || Decidim::Pokecode.language_menu_enabled
    end

    def self.sentry_enabled
      Pokecode.sentry_dsn.present?
    end

    def self.admin_iframe_enabled
      Pokecode.admin_iframe_url.present?
    end

    def self.analytics_enabled
      Pokecode.umami_analytics_id.present? && Pokecode.umami_analytics_url.present?
    end
  end
end
