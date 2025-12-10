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

          iframe_host = URI.parse(Decidim::Pokecode.admin_iframe_url)&.host
          return if iframe_host.blank?

          content_security_policy.append_csp_directive("frame-src", iframe_host)
        end
      end
    end
  end
end
