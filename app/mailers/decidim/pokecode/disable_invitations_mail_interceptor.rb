# frozen_string_literal: true

module Decidim
  module Pokecode
    # Email interceptor that prevents invitation emails from being sent.
    # Disables all emails that contain the 'invitation-instructions' header.
    class DisableInvitationsMailInterceptor
      def self.delivering_email(message)
        return unless Decidim::Pokecode.disable_invitations

        # Check if this is an invitation email
        if message["invitation-instructions"].present?
          Rails.logger.info "[Decidim::Pokecode] Invitation email prevented. Instructions: #{message["invitation-instructions"]}, To: #{message.to.join(", ")}"
          message.perform_deliveries = false
        end
      end
    end
  end
end
