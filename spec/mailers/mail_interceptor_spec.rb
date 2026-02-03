# frozen_string_literal: true

require "spec_helper"

module Decidim::Pokecode
  describe AllowedRecipientsMailInterceptor do
    let(:message) do
      instance_double(
        Mail::Message,
        to: to_recipients,
        cc: cc_recipients,
        bcc: bcc_recipients,
        perform_deliveries: true
      )
    end

    let(:to_recipients) { [] }
    let(:cc_recipients) { [] }
    let(:bcc_recipients) { [] }
    let(:allowed_recipients) { [] }

    before do
      allow(Rails.logger).to receive(:warn)
      allow(Rails.logger).to receive(:info)
      allow(message).to receive(:to=)
      allow(message).to receive(:cc=)
      allow(message).to receive(:bcc=)
      allow(message).to receive(:perform_deliveries=)
    end

    describe ".delivering_email" do
      before do
        allow(Decidim::Pokecode).to receive(:allowed_recipients_list).and_return(allowed_recipients)
      end

      context "when allowed_recipients is empty" do
        it "does not intercept the email" do
          described_class.delivering_email(message)
          expect(message).not_to have_received(:perform_deliveries=)
        end
      end

      context "when allowed_recipients is configured" do
        context "with domain-based allowed recipients" do
          let(:allowed_recipients) { ["@pokecode.net"] }

          context "when recipients match the allowed domain" do
            let(:to_recipients) { ["user@pokecode.net", "admin@pokecode.net"] }

            it "allows the email" do
              described_class.delivering_email(message)
              expect(message).not_to have_received(:perform_deliveries=)
              expect(message).to have_received(:to=).with(["user@pokecode.net", "admin@pokecode.net"].uniq)
            end

            it "logs the filtering" do
              described_class.delivering_email(message)
              expect(Rails.logger).to have_received(:info)
            end
          end

          context "when recipients don't match the allowed domain" do
            let(:to_recipients) { ["user@example.com", "admin@gmail.com"] }

            it "blocks the email" do
              described_class.delivering_email(message)
              expect(message).to have_received(:perform_deliveries=).with(false)
            end

            it "logs the interception" do
              described_class.delivering_email(message)
              expect(Rails.logger).to have_received(:warn)
            end
          end

          context "with mixed recipients" do
            let(:to_recipients) { ["user@pokecode.net", "admin@example.com"] }
            let(:cc_recipients) { ["cc@pokecode.net"] }
            let(:bcc_recipients) { ["bcc@gmail.com"] }

            it "filters to only allowed recipients" do
              described_class.delivering_email(message)
              expect(message).to have_received(:to=).with(["user@pokecode.net"])
              expect(message).to have_received(:cc=).with(["cc@pokecode.net"])
              expect(message).to have_received(:bcc=).with([])
            end
          end
        end

        context "with exact email allowed recipients" do
          let(:allowed_recipients) { ["john@example.com", "jane@example.com"] }

          context "when recipients match exactly" do
            let(:to_recipients) { ["john@example.com"] }

            it "allows the email" do
              described_class.delivering_email(message)
              expect(message).not_to have_received(:perform_deliveries=)
              expect(message).to have_received(:to=).with(["john@example.com"])
            end
          end

          context "when recipients don't match" do
            let(:to_recipients) { ["bob@example.com"] }

            it "blocks the email" do
              described_class.delivering_email(message)
              expect(message).to have_received(:perform_deliveries=).with(false)
            end
          end
        end

        context "with mixed allowed recipients" do
          let(:allowed_recipients) { ["@pokecode.net", "external@gmail.com"] }

          context "when recipients match domain or exact email" do
            let(:to_recipients) { ["user@pokecode.net", "external@gmail.com"] }

            it "allows the email" do
              described_class.delivering_email(message)
              expect(message).not_to have_received(:perform_deliveries=)
              expect(message).to have_received(:to=).with(["user@pokecode.net", "external@gmail.com"])
            end
          end

          context "when some recipients don't match" do
            let(:to_recipients) { ["user@pokecode.net", "other@gmail.com"] }

            it "filters to only allowed recipients" do
              described_class.delivering_email(message)
              expect(message).to have_received(:to=).with(["user@pokecode.net"])
            end
          end
        end

        context "with case-insensitive matching" do
          let(:allowed_recipients) { ["@pokecode.net", "John@Example.Com"] }

          context "with uppercase recipients" do
            let(:to_recipients) { ["USER@POKECODE.NET", "JOHN@EXAMPLE.COM"] }

            it "matches case-insensitively" do
              described_class.delivering_email(message)
              expect(message).to have_received(:to=).with(["user@pokecode.net", "john@example.com"])
            end
          end

          context "with mixed case recipients" do
            let(:to_recipients) { ["user@PokeCode.Net", "John@example.com"] }

            it "matches case-insensitively" do
              described_class.delivering_email(message)
              expect(message).to have_received(:to=).with(["user@pokecode.net", "john@example.com"])
            end
          end
        end

        context "when only BCC recipients match" do
          let(:allowed_recipients) { ["@pokecode.net"] }
          let(:bcc_recipients) { ["admin@pokecode.net"] }

          it "allows the email with only BCC" do
            described_class.delivering_email(message)
            expect(message).to have_received(:bcc=).with(["admin@pokecode.net"])
          end
        end
      end
    end
  end
end
