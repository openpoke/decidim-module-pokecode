# frozen_string_literal: true

require "spec_helper"
require "aws-sdk-s3"
require "decidim/pokecode/s3_object_override"

module Decidim
  describe Pokecode do
    if Decidim::Pokecode.health_check_enabled
      it "loads HealthCheck" do
        expect(defined?(HealthCheck)).to be_truthy
        expect(Rails.application.config.ssl_options[:redirect][:exclude].call(OpenStruct.new(path: "/health_check"))).to be_truthy
      end
    else
      it "does not load HealthCheck" do
        expect(defined?(HealthCheck)).to be_falsey
        expect(Rails.application.config.ssl_options[:redirect]).to be_nil
      end
    end

    if Decidim::Pokecode.semantic_logger_enabled
      it "loads RailsSemanticLogger" do
        expect(defined?(RailsSemanticLogger)).to be_truthy
      end
    else
      it "does not load RailsSemanticLogger" do
        expect(defined?(RailsSemanticLogger)).to be_falsey
      end
    end

    if Decidim::Pokecode.sentry_enabled
      it "loads Sentry" do
        expect(defined?(Sentry)).to be_truthy
      end
    else
      it "does not load Sentry" do
        expect(defined?(Sentry)).to be_falsey
      end
    end

    if Decidim::Pokecode.sidekiq_enabled
      it "loads Sidekiq" do
        expect(defined?(Sidekiq)).to be_truthy
      end
    else
      it "does not load Sidekiq" do
        expect(defined?(Sidekiq)).to be_falsey
      end
    end

    if Decidim::Pokecode.deface_enabled
      it "loads Deface" do
        expect(defined?(Deface)).to be_truthy
      end
    else
      it "does not load Deface" do
        expect(defined?(Deface)).to be_falsey
      end
    end

    if Decidim::Pokecode.aws_cdn_host.present?
      it "loads Aws::S3" do
        expect(Aws::S3::Object.included_modules).to include(Decidim::Pokecode::S3ObjectOverride)
      end
    else
      it "does not load Aws::S3" do
        expect(Aws::S3::Object.included_modules).not_to include(Decidim::Pokecode::S3ObjectOverride)
      end
    end

    if Decidim::Pokecode.analytics_enabled
      it "loads NeedsAnalyticsCspDirectives" do
        expect(Decidim::ApplicationController.included_modules).to include(Decidim::Pokecode::NeedsAnalyticsCspDirectives)
      end
    else
      it "does not load NeedsAnalyticsCspDirectives" do
        expect(Decidim::ApplicationController.included_modules).not_to include(Decidim::Pokecode::NeedsAnalyticsCspDirectives)
      end
    end

    if Decidim::Pokecode.active_storage_s3_urls.present?
      it "loads NeedsStorageCspDirectives" do
        expect(Decidim::ApplicationController.included_modules).to include(Decidim::Pokecode::NeedsStorageCspDirectives)
      end
    else
      it "does not load NeedsStorageCspDirectives" do
        expect(Decidim::ApplicationController.included_modules).not_to include(Decidim::Pokecode::NeedsStorageCspDirectives)
      end
    end

    if Decidim::Pokecode.assembly_members_visible_enabled
      it "loads AssemblyOverride" do
        expect(Decidim::Assembly.included_modules).to include(Decidim::Pokecode::AssemblyOverride)
        expect(Decidim::Assemblies::Permissions.included_modules).to include(Decidim::Pokecode::AssembliesPermissionsOverride)
      end
    else
      it "does not load AssemblyOverride" do
        expect(Decidim::Assembly.included_modules).not_to include(Decidim::Pokecode::AssemblyOverride)
        expect(Decidim::Assemblies::Permissions.included_modules).not_to include(Decidim::Pokecode::AssembliesPermissionsOverride)
      end
    end
  end
end
