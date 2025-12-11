# frozen_string_literal: true

require "spec_helper"
require "rack/attack"

describe "Rack::Attack" do
  describe "rack_attack_allowed_ips" do
    let(:allowed_ips) { "" }
    let(:skip_param) { "" }

    before do
      allow(Decidim::Pokecode).to receive(:rack_attack_allowed_ips).and_return(allowed_ips)
      allow(Decidim::Pokecode).to receive(:rack_attack_skip_param).and_return(skip_param)
    end

    it "defaults to first 6 characters of Rails secret when env var not set" do
      ips = Decidim::Pokecode.rack_attack_ips
      param = Decidim::Pokecode.rack_attack_skip
      expected_default = Rails.application.secrets.secret_key_base&.first(6)

      expect(ips).to be_an(Array)
      expect(param).to include(expected_default)
      expect(Rack::Attack.safelists.keys).to include("bypass with secret param")
    end

    context "when RACK_ATTACK_ALLOWED_IPS is set" do
      let(:allowed_ips) { "10.0.0.1/24,11.10.0.1 1.1.1.1" }

      it "returns the allowed IPs as an array" do
        ips = Decidim::Pokecode.rack_attack_ips
        expect(ips).to eq(["10.0.0.1/24", "11.10.0.1", "1.1.1.1"])
        expect(Rack::Attack.safelists.keys).to include("bypass with secret param")
      end
    end

    context "when RACK_ATTACK_SKIP_PARAM is set" do
      let(:skip_param) { "my-secret-param" }

      it "returns the skip param" do
        param = Decidim::Pokecode.rack_attack_skip
        expect(param).to eq("my-secret-param")
        expect(Rack::Attack.safelists.keys).to include("bypass with secret param")
      end
    end
  end
end
