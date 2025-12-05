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

    if Decidim::Pokecode.deface_enabled?
      it "loads Deface" do
        expect(defined?(Deface)).to be_truthy
      end
    else
      it "does not load Deface" do
        expect(defined?(Deface)).to be_falsey
      end
    end
  end
end
