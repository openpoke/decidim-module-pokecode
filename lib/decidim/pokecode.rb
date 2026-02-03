# frozen_string_literal: true

require "decidim/pokecode/configuration"
require "rails"
require "decidim/core"
require "health_check" if Decidim::Pokecode.health_check_enabled
require "rails_semantic_logger" if Decidim::Pokecode.semantic_logger_enabled
require "deface" if Decidim::Pokecode.deface_enabled
require "aws-sdk-s3" if Decidim::Pokecode.aws_cdn_host.present?
require "decidim/pokecode/s3_object_override" if Decidim::Pokecode.aws_cdn_host.present?

if Decidim::Pokecode.sentry_enabled
  require "sentry-ruby"
  require "sentry-rails"
end

if Decidim::Pokecode.sidekiq_enabled
  require "sidekiq"
  require "sidekiq/cron"
end

require "decidim/pokecode/admin"
require "decidim/pokecode/engine"
require "decidim/pokecode/admin_engine"
