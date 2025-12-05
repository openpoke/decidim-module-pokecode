# frozen_string_literal: true

require "decidim/pokecode/configuration"
require "rails"
require "decidim/core"
require "health_check" if Decidim::Pokecode.health_check_enabled
require "rails_semantic_logger" if Decidim::Pokecode.semantic_logger_enabled
require "deface" if Decidim::Pokecode.deface_enabled?
if Decidim::Pokecode.sentry_enabled?
  require "sentry-ruby"
  require "sentry-rails"
end
require "sidekiq"
require "sidekiq-cron"

require "decidim/pokecode/admin"
require "decidim/pokecode/engine"
require "decidim/pokecode/admin_engine"
