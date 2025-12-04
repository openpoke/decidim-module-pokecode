# frozen_string_literal: true

module Decidim
  module Pokecode
    include ActiveSupport::Configurable

    config_accessor :health_check_enabled do
      Decidim::Env.new("DISABLE_HEALTH_CHECK", false).blank?
    end

    config_accessor :semantic_logger_enabled do
      Decidim::Env.new("DISABLE_SEMANTIC_LOGGER", false).blank?
    end
  end
end
