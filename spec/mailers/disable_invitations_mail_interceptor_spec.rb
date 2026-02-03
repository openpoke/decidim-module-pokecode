# frozen_string_literal: true

require "spec_helper"
require "decidim/pokecode/disable_invitations_mail_interceptor"

module Decidim::Pokecode
  describe DisableInvitationsMailInterceptor do
    let(:message) do
      instance_double(
        Mail::Message,
        to: ["user@example.com"],
        perform_deliveries: true
      )
    end

    before do
      allow(Rails.logger).to receive(:info)
      allow(message).to receive(:perform_deliveries=)
      allow(message).to receive(:[]).and_return(nil)
    end

    describe ".delivering_email" do
      context "when disable_invitations is disabled" do
        before do
          allow(Decidim::Pokecode).to receive(:disable_invitations).and_return(false)
        end

        it "does not intercept any emails" do
          allow(message).to receive(:[]).with("invitation-instructions").and_return("invite_private_user")
          described_class.delivering_email(message)
          expect(message).not_to have_received(:perform_deliveries=)
        end
      end

      context "when disable_invitations is enabled" do
        before do
          allow(Decidim::Pokecode).to receive(:disable_invitations).and_return(true)
        end

        context "when the email has an invitation-instructions header" do
          before do
            allow(message).to receive(:[]).with("invitation-instructions").and_return("invite_private_user")
          end

          it "prevents the email from being delivered" do
            described_class.delivering_email(message)
            expect(message).to have_received(:perform_deliveries=).with(false)
          end

          it "logs the interception" do
            described_class.delivering_email(message)
            expect(Rails.logger).to have_received(:info).with(
              include("[Decidim::Pokecode] Invitation email prevented")
            )
          end
        end

        context "when the email does not have an invitation-instructions header" do
          before do
            allow(message).to receive(:[]).with("invitation-instructions").and_return(nil)
          end

          it "allows the email to be delivered" do
            described_class.delivering_email(message)
            expect(message).not_to have_received(:perform_deliveries=)
          end

          it "does not log the interception" do
            described_class.delivering_email(message)
            expect(Rails.logger).not_to have_received(:info)
          end
        end
      end
    end
  end
end
