# frozen_string_literal: true

module Decidim
  module Pokecode
    mattr_accessor :health_check_enabled,
                   default: Decidim::Env.new("DISABLE_HEALTH_CHECK", false).blank?

    mattr_accessor :semantic_logger_enabled,
                   default: Decidim::Env.new("DISABLE_SEMANTIC_LOGGER", false).blank?

    mattr_accessor :sidekiq_enabled,
                   default: Decidim::Env.new("DISABLE_SIDEKIQ", false).blank?

    mattr_accessor :queue_adapter,
                   default: Decidim::Env.new("QUEUE_ADAPTER", Decidim::Env.new("DISABLE_SIDEKIQ", false).blank? ? "sidekiq" : "").value
    mattr_accessor :sentry_dsn,
                   default: Decidim::Env.new("SENTRY_DSN", "").value

    mattr_accessor :admin_iframe_url,
                   default: Decidim::Env.new("ADMIN_IFRAME_URL", "").value

    mattr_accessor :admin_iframe_title,
                   default: Decidim::Env.new("ADMIN_IFRAME_TITLE", "Web Stats").value

    mattr_accessor :pokecode_footer_enabled,
                   default: Decidim::Env.new("DISABLE_POKECODE_FOOTER", false).blank?

    mattr_accessor :language_menu_enabled,
                   default: Decidim::Env.new("DISABLE_LANGUAGE_MENU", false).blank?

    mattr_accessor :umami_analytics_id,
                   default: Decidim::Env.new("UMAMI_ANALYTICS_ID", "").value

    mattr_accessor :umami_analytics_url,
                   default: Decidim::Env.new("UMAMI_ANALYTICS_URL", "https://analytics.pokecode.net/script.js").value

    mattr_accessor :rack_attack_skip_param,
                   default: Decidim::Env.new("RACK_ATTACK_SKIP_PARAM", nil).value

    mattr_accessor :rack_attack_allowed_ips,
                   default: Decidim::Env.new("RACK_ATTACK_ALLOWED_IPS", nil).value

    mattr_accessor :aws_cdn_host,
                   default: begin
                     host = Decidim::Env.new("AWS_CDN_HOST", "").value
                     host.present? && host.starts_with?("https://") ? host : ""
                   end

    mattr_accessor :allowed_recipients,
                   default: Decidim::Env.new("ALLOWED_RECIPIENTS", "").value

    mattr_accessor :disable_invitations,
                   default: Decidim::Env.new("DISABLE_INVITATIONS", false).present?

    mattr_accessor :content_security_policies_extra,
                   default: {
                     "connect-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split,
                     "img-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split,
                     "default-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split,
                     "script-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split,
                     "style-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split,
                     "font-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split,
                     "frame-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split,
                     "media-src" => ENV.fetch("CONTENT_SECURITY_POLICY", "").split
                   }

    mattr_accessor :email_white_header_enabled,
                   default: Decidim::Env.new("DISABLE_EMAIL_WHITE_HEADER", false).blank?

    mattr_accessor :unsafe_html_blocks,
                   default: Decidim::Env.new("UNSAFE_HTML_BLOCKS", false).present?

    def self.rack_attack_skip
      Pokecode.rack_attack_skip_param || Rails.application.secret_key_base&.first(6)
    end

    def self.rack_attack_ips
      Pokecode.rack_attack_allowed_ips&.split(/[,\s]+/)&.reject(&:blank?) || []
    end

    def self.allowed_recipients_list
      Pokecode.allowed_recipients&.split(/[,\s]+/)&.reject(&:blank?) || []
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
