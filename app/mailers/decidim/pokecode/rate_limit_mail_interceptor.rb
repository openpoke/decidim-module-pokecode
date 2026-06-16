# frozen_string_literal: true

module Decidim
  module Pokecode
    # Email interceptor that enforces daily and/or monthly sending quotas.
    # When a quota is exceeded the email is not delivered, a warning is logged,
    # and an ActiveSupport::Notifications event is published so that subscribers
    # can react (e.g. alert an operator).
    #
    # Quotas are stored in Redis and controlled via two ENV variables:
    #   ACTION_MAILER_MAX_EMAILS_PER_DAY   – maximum emails allowed per calendar day
    #   ACTION_MAILER_MAX_EMAILS_PER_MONTH – maximum emails allowed per calendar month
    class RateLimitMailInterceptor
      # Event name published when an email is skipped due to quota being exceeded.
      QUOTA_EXCEEDED_EVENT = "decidim.pokecode.mail_quota_exceeded"

      def self.delivering_email(message)
        return unless Decidim::Pokecode.rate_limit_enabled?

        quota = MailQuota.new

        if daily_limit_exceeded?(quota)
          skip_delivery!(message, :daily, quota.daily_count, Decidim::Pokecode.max_emails_per_day)
        elsif monthly_limit_exceeded?(quota)
          skip_delivery!(message, :monthly, quota.monthly_count, Decidim::Pokecode.max_emails_per_month)
        else
          quota.increment!
        end
      end

      def self.daily_limit_exceeded?(quota)
        limit = Decidim::Pokecode.max_emails_per_day
        limit.present? && quota.daily_count >= limit
      end

      def self.monthly_limit_exceeded?(quota)
        limit = Decidim::Pokecode.max_emails_per_month
        limit.present? && quota.monthly_count >= limit
      end

      def self.skip_delivery!(message, period, current_count, limit)
        message.perform_deliveries = false

        Rails.logger.warn(
          "[Decidim::Pokecode] Email delivery skipped: #{period} quota exceeded " \
          "(#{current_count}/#{limit}). To: #{Array(message.to).join(", ")}"
        )

        ActiveSupport::Notifications.instrument(
          QUOTA_EXCEEDED_EVENT,
          period: period,
          current_count: current_count,
          limit: limit,
          recipients: Array(message.to)
        )
      end
    end
  end
end
