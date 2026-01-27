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

    config_accessor :queue_adapter do
      Decidim::Env.new("QUEUE_ADAPTER", Decidim::Env.new("DISABLE_SIDEKIQ", false).blank? ? "sidekiq" : "").value
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

    config_accessor :attachment_can_participate_override_enabled do
      Decidim::Env.new("DISABLE_ATTACHMENT_CAN_PARTICIPATE_OVERRIDE", false).blank?
    end

    config_accessor :umami_analytics_id do
      Decidim::Env.new("UMAMI_ANALYTICS_ID", "").value
    end

    config_accessor :umami_analytics_url do
      Decidim::Env.new("UMAMI_ANALYTICS_URL", "https://analytics.pokecode.net/script.js").value
    end

    config_accessor :rack_attack_skip_param do
      Decidim::Env.new("RACK_ATTACK_SKIP_PARAM", nil).value
    end

    config_accessor :rack_attack_allowed_ips do
      Decidim::Env.new("RACK_ATTACK_ALLOWED_IPS", nil).value
    end

    config_accessor :aws_cdn_host do
      host = Decidim::Env.new("AWS_CDN_HOST", "").value
      host.present? && host.starts_with?("https://") ? host : ""
    end

    config_accessor :allowed_recipients do
      Decidim::Env.new("ALLOWED_RECIPIENTS", "").value
    end

    config_accessor :content_security_policies_extra do
      {
        "connect-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split,
        "img-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split,
        "default-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split,
        "script-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split,
        "style-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split,
        "font-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split,
        "frame-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split,
        "media-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split
      }
    end

    def self.rack_attack_skip
      Pokecode.rack_attack_skip_param || Rails.application.secret_key_base&.first(6)
    end

    def self.rack_attack_ips
      Pokecode.rack_attack_allowed_ips&.split(/[,\s]+/)&.reject(&:blank?) || []
    end

    def self.allowed_recipients_list
      Pokecode.allowed_recipients&.split(/[,\s]+/)&.reject(&:blank?) || []
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

    def self.active_storage_s3_urls
      urls = []
      urls << Pokecode.aws_cdn_host if Pokecode.aws_cdn_host.present?
      urls << ActiveStorage::Blob.service.bucket.url if defined?(ActiveStorage::Service::S3Service) && ActiveStorage::Blob.service.is_a?(ActiveStorage::Service::S3Service)
      urls
    end
  end
end
