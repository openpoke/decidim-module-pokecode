# frozen_string_literal: true

module Decidim
  module Pokecode
    # Concern to provide a small, safe override / helpers for analytics related to Needs.
    # Include this in controllers that handle Decidim::Need resources to build
    # consistent payloads and to send events with pokecode metadata.
    module NeedsAnalyticsOverride
      extend ActiveSupport::Concern

      included do
        before_action :add_analytics_csp_directives
      end

      private

      def add_analytics_csp_directives
        return unless Decidim::Pokecode.analytics_enabled

        analytics_uri = begin
          URI.parse(Decidim::Pokecode.umami_analytics_url)
        rescue URI::InvalidURIError
          nil
        end
        return if analytics_uri.host.blank? || analytics_uri.scheme.blank?

        origin = "#{analytics_uri.scheme}://#{analytics_uri.host}"
        origin += ":#{analytics_uri.port}" if analytics_uri.port && [80, 443].exclude?(analytics_uri.port)
        content_security_policy.append_csp_directive("script-src", origin)
      end
    end
  end
end
