# frozen_string_literal: true

module Decidim
  module Pokecode
    # Provides read/write access to the email sending quota stored in Redis.
    # Counters are stored with keys scoped by day and month and expire
    # automatically when the period rolls over.
    #
    # Usage:
    #   quota = Decidim::Pokecode::MailQuota.new
    #   quota.daily_count    # => Integer
    #   quota.monthly_count  # => Integer
    #   quota.increment!     # increments both counters
    class MailQuota
      DAILY_KEY_PREFIX = "decidim:pokecode:mail_quota:daily"
      MONTHLY_KEY_PREFIX = "decidim:pokecode:mail_quota:monthly"

      # Returns the current number of emails sent today.
      def daily_count
        redis.get(daily_key).to_i
      end

      # Returns the current number of emails sent this month.
      def monthly_count
        redis.get(monthly_key).to_i
      end

      # Increments both the daily and monthly counters and sets their TTL
      # (so they expire automatically at the end of each period).
      def increment!
        now = Time.current

        redis.multi do |pipeline|
          pipeline.incr(daily_key)
          pipeline.expireat(daily_key, end_of_day(now).to_i)

          pipeline.incr(monthly_key)
          pipeline.expireat(monthly_key, end_of_month(now).to_i)
        end
      end

      # Returns the Redis key for the current day's counter.
      def daily_key
        "#{DAILY_KEY_PREFIX}:#{Time.current.strftime("%Y-%m-%d")}"
      end

      # Returns the Redis key for the current month's counter.
      def monthly_key
        "#{MONTHLY_KEY_PREFIX}:#{Time.current.strftime("%Y-%m")}"
      end

      private

      def redis
        @redis ||= Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"))
      end

      def end_of_day(time)
        time.end_of_day
      end

      def end_of_month(time)
        time.end_of_month
      end
    end
  end
end
