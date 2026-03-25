# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe Pokecode do
    subject { described_class }

    it "has version" do
      expect(subject::VERSION).to eq("0.3.0")
      expect(subject::COMPAT_DECIDIM_VERSION).to eq([">= 0.31.2", "< 0.32"])
    end
  end
end
