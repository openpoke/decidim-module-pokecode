# frozen_string_literal: true

require "spec_helper"

class CspController < Decidim::ApplicationController; end
describe CspController do
  controller(CspController) do
    def index
      head :ok
    end
  end
  before do
    routes.draw do
      get "index" => "csp#index"
    end
  end

  describe "CSP" do
    if Decidim::Pokecode.analytics_enabled
      it "includes analytics CSP directives" do
        controller.send(:add_analytics_csp_directives)
        get :index, params: {}
        csp = controller.content_security_policy.output_policy
        expect(csp).to include("https://analytics.pokecode.net")
      end
    else
      it "does not include analytics CSP directives" do
        get :index, params: {}
        csp = controller.content_security_policy.output_policy
        expect(csp).not_to include("https://analytics.pokecode.net")
      end
    end

    context "when Active Storage S3 URLs are configured" do
      if Decidim::Pokecode.active_storage_s3_urls.present?
        it "includes Active Storage S3 CSP directives" do
          controller.send(:add_storage_csp_directives)
          get :index, params: {}
          csp = controller.content_security_policy.output_policy
          expect(csp).to include("https://cdn.example.com")
        end
      else
        it "does not include Active Storage S3 CSP directives" do
          get :index, params: {}
          csp = controller.content_security_policy.output_policy
          expect(csp).not_to include("https://cdn.example.com")
        end
      end
    end
  end
end
