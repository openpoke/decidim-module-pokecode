# frozen_string_literal: true

module Decidim
  module Pokecode
    # Email interceptor that filters outgoing emails based on allowed recipients.
    # Only allows emails to recipients that match the configured allowed list.
    class AllowedRecipientsMailInterceptor
      def self.delivering_email(message)
        return if allowed_recipients_empty?

        # Get all recipients from the email message
        to_recipients = Array(message.to).map(&:downcase)
        cc_recipients = Array(message.cc).map(&:downcase)
        bcc_recipients = Array(message.bcc).map(&:downcase)

        all_recipients = to_recipients + cc_recipients + bcc_recipients

        # Filter recipients to only those in the allowed list
        filtered_recipients = all_recipients.select { |recipient| allowed?(recipient) }
        if filtered_recipients.empty?
          Rails.logger.warn "[Decidim::Pokecode] Email delivery intercepted. No recipients matched allowed list. Original recipients: #{all_recipients.join(", ")}"
          message.perform_deliveries = false
        else
          # Update the message with only the allowed recipients
          message.to = (to_recipients & filtered_recipients).uniq
          message.cc = (cc_recipients & filtered_recipients).uniq
          message.bcc = (bcc_recipients & filtered_recipients).uniq

          Rails.logger.info "[Decidim::Pokecode] Email delivery filtered. Original recipients: #{all_recipients.join(", ")}, Allowed recipients: #{filtered_recipients.join(", ")}"
        end
      end

      def self.allowed_recipients_empty?
        Decidim::Pokecode.allowed_recipients_list.empty?
      end

      def self.allowed?(email)
        email_lowercase = email.downcase
        Decidim::Pokecode.allowed_recipients_list.any? do |allowed|
          allowed_lowercase = allowed.downcase
          # Check if the email matches or ends with the allowed value
          # This allows both exact email matches and domain-based matches (e.g., @pokecode.net)
          email_lowercase == allowed_lowercase || email_lowercase.end_with?(allowed_lowercase.to_s.start_with?("@") ? allowed_lowercase : "@#{allowed_lowercase}")
        end
      end
    end
  end
end
