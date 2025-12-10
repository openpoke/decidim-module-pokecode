# frozen_string_literal: true

module Decidim
  module Pokecode
    module Admin
      class IframeController < Decidim::Admin::ApplicationController
        before_action :add_additional_csp_directives
        def index
          enforce_permission_to :read, :admin_dashboard
        end

        private

        def add_additional_csp_directives
          return unless Decidim::Pokecode.admin_iframe_enabled

          iframe_uri = begin
            URI.parse(Decidim::Pokecode.admin_iframe_url)
          rescue URI::InvalidURIError
            nil
          end
          return if iframe_uri.host.blank? || iframe_uri.scheme.blank?

          origin = "#{iframe_uri.scheme}://#{iframe_uri.host}"
          origin += ":#{iframe_uri.port}" if iframe_uri.port && [80, 443].exclude?(iframe_uri.port)
          content_security_policy.append_csp_directive("frame-src", origin)
        end
      end
    end
  end
end
