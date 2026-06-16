# frozen_string_literal: true

require "spec_helper"

module Decidim::Pokecode
  describe RateLimitMailInterceptor do
    let(:message) do
      instance_double(
        Mail::Message,
        to: ["user@example.com"],
        perform_deliveries: true
      )
    end

    let(:quota) { instance_double(MailQuota, daily_count: 0, monthly_count: 0) }

    before do
      allow(Rails.logger).to receive(:warn)
      allow(Rails.logger).to receive(:info)
      allow(message).to receive(:perform_deliveries=)
      allow(MailQuota).to receive(:new).and_return(quota)
      allow(quota).to receive(:increment!)
    end

    describe ".delivering_email" do
      context "when rate limiting is disabled (no limits configured)" do
        before do
          allow(Decidim::Pokecode).to receive(:rate_limit_enabled?).and_return(false)
        end

        it "does not check quota" do
          described_class.delivering_email(message)
          expect(MailQuota).not_to have_received(:new)
        end

        it "does not block delivery" do
          described_class.delivering_email(message)
          expect(message).not_to have_received(:perform_deliveries=)
        end
      end

      context "when rate limiting is enabled" do
        before do
          allow(Decidim::Pokecode).to receive(:rate_limit_enabled?).and_return(true)
          allow(Decidim::Pokecode).to receive(:max_emails_per_day).and_return(max_per_day)
          allow(Decidim::Pokecode).to receive(:max_emails_per_month).and_return(max_per_month)
        end

        let(:max_per_day) { nil }
        let(:max_per_month) { nil }

        context "when daily limit is set and not exceeded" do
          let(:max_per_day) { 100 }

          before do
            allow(quota).to receive(:daily_count).and_return(50)
          end

          it "allows delivery and increments quota" do
            described_class.delivering_email(message)
            expect(message).not_to have_received(:perform_deliveries=)
            expect(quota).to have_received(:increment!)
          end
        end

        context "when daily limit is set and exactly reached" do
          let(:max_per_day) { 100 }

          before do
            allow(quota).to receive(:daily_count).and_return(100)
          end

          it "blocks delivery" do
            described_class.delivering_email(message)
            expect(message).to have_received(:perform_deliveries=).with(false)
          end

          it "logs a warning" do
            described_class.delivering_email(message)
            expect(Rails.logger).to have_received(:warn).with(include("daily quota exceeded"))
          end

          it "publishes a quota exceeded event" do
            events = []
            ActiveSupport::Notifications.subscribed(
              ->(name, _start, _finish, _id, payload) { events << { name: name, payload: payload } },
              RateLimitMailInterceptor::QUOTA_EXCEEDED_EVENT
            ) do
              described_class.delivering_email(message)
            end

            expect(events.length).to eq(1)
            expect(events.first[:payload][:period]).to eq(:daily)
            expect(events.first[:payload][:current_count]).to eq(100)
            expect(events.first[:payload][:limit]).to eq(100)
          end

          it "does not increment quota" do
            described_class.delivering_email(message)
            expect(quota).not_to have_received(:increment!)
          end
        end

        context "when daily limit is exceeded" do
          let(:max_per_day) { 50 }

          before do
            allow(quota).to receive(:daily_count).and_return(75)
          end

          it "blocks delivery" do
            described_class.delivering_email(message)
            expect(message).to have_received(:perform_deliveries=).with(false)
          end

          it "logs a warning with count and limit" do
            described_class.delivering_email(message)
            expect(Rails.logger).to have_received(:warn).with(include("75/50"))
          end
        end

        context "when monthly limit is set and not exceeded" do
          let(:max_per_month) { 1000 }

          before do
            allow(quota).to receive(:monthly_count).and_return(500)
          end

          it "allows delivery and increments quota" do
            described_class.delivering_email(message)
            expect(message).not_to have_received(:perform_deliveries=)
            expect(quota).to have_received(:increment!)
          end
        end

        context "when monthly limit is reached" do
          let(:max_per_month) { 1000 }

          before do
            allow(quota).to receive(:monthly_count).and_return(1000)
          end

          it "blocks delivery" do
            described_class.delivering_email(message)
            expect(message).to have_received(:perform_deliveries=).with(false)
          end

          it "logs a warning" do
            described_class.delivering_email(message)
            expect(Rails.logger).to have_received(:warn).with(include("monthly quota exceeded"))
          end

          it "publishes a monthly quota exceeded event" do
            events = []
            ActiveSupport::Notifications.subscribed(
              ->(name, _start, _finish, _id, payload) { events << { name: name, payload: payload } },
              RateLimitMailInterceptor::QUOTA_EXCEEDED_EVENT
            ) do
              described_class.delivering_email(message)
            end

            expect(events.length).to eq(1)
            expect(events.first[:payload][:period]).to eq(:monthly)
          end
        end

        context "when both daily and monthly limits are set" do
          let(:max_per_day) { 10 }
          let(:max_per_month) { 100 }

          context "when daily limit is exceeded" do
            before do
              allow(quota).to receive(:daily_count).and_return(10)
              allow(quota).to receive(:monthly_count).and_return(50)
            end

            it "blocks on daily limit and does not check monthly" do
              described_class.delivering_email(message)
              expect(message).to have_received(:perform_deliveries=).with(false)
              expect(Rails.logger).to have_received(:warn).with(include("daily quota exceeded"))
            end
          end

          context "when only monthly limit is exceeded" do
            before do
              allow(quota).to receive(:daily_count).and_return(5)
              allow(quota).to receive(:monthly_count).and_return(100)
            end

            it "blocks on monthly limit" do
              described_class.delivering_email(message)
              expect(message).to have_received(:perform_deliveries=).with(false)
              expect(Rails.logger).to have_received(:warn).with(include("monthly quota exceeded"))
            end
          end

          context "when neither limit is exceeded" do
            before do
              allow(quota).to receive(:daily_count).and_return(5)
              allow(quota).to receive(:monthly_count).and_return(50)
            end

            it "allows delivery and increments quota" do
              described_class.delivering_email(message)
              expect(message).not_to have_received(:perform_deliveries=)
              expect(quota).to have_received(:increment!)
            end
          end
        end
      end
    end
  end
end
