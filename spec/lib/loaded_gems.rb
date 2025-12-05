# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Pokecode do
    if Decidim::Pokecode.health_check_enabled
      it "loads HealthCheck" do
        expect(defined?(HealthCheck)).to be_truthy
      end
    else
      it "does not load HealthCheck" do
        expect(defined?(HealthCheck)).to be_falsey
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
