# frozen_string_literal: true

module Decidim
  module Pokecode
    # Concern to add Content Security Policy (CSP) directives for Active Storage S3 URLs.
    # Include this in controllers (such as ApplicationController) that need to allow S3-hosted assets
    # by appending the appropriate CSP directives for those storage URLs.
    module NeedsStorageCspDirectives
      extend ActiveSupport::Concern

      included do
        before_action :add_storage_csp_directives
      end

      private

      def add_storage_csp_directives
        return if Decidim::Pokecode.active_storage_s3_urls.blank?

        Decidim::Pokecode.active_storage_s3_urls.each do |url|
          uri = begin
            URI.parse(url)
          rescue URI::InvalidURIError
            Rails.logger.warn "[Decidim::Pokecode] Invalid Active Storage S3 URL for CSP directives (#{url})."
            nil
          end
          next unless uri && uri.host.present? && uri.scheme.present?

          origin = "#{uri.scheme}://#{uri.host}"
          origin += ":#{uri.port}" if uri.port && [80, 443].exclude?(uri.port)

          content_security_policy.append_csp_directive("default-src", origin)
          content_security_policy.append_csp_directive("img-src", origin)
          content_security_policy.append_csp_directive("media-src", origin)
          content_security_policy.append_csp_directive("connect-src", origin)
        end
      end
    end
  end
end
