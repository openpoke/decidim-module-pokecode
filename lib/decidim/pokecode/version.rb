# frozen_string_literal: true

module Decidim
  # This holds the decidim-meetings version.
  module Pokecode
    COMPAT_DECIDIM_VERSION = [">= 0.30.0", "< 0.31"].freeze

    def self.version
      "0.1.0"
    end
  end
end
