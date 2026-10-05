# frozen_string_literal: true

require "spec_helper"

describe Decidim::Pokecode::JobRetries do
  let(:handlers) { Decidim::ExportJob.rescue_handlers.map(&:first) }
  let(:mail_handlers) { ActionMailer::MailDeliveryJob.rescue_handlers.map(&:first) }

  if Decidim::Pokecode.solid_queue_enabled
    it "retries any error but keeps discarding deserialization errors first" do
      expect(handlers).to include("StandardError")
      expect(handlers.last).to eq("ActiveJob::DeserializationError")
    end

    it "retries mail deliveries" do
      expect(mail_handlers.last).to eq("ActiveJob::DeserializationError")
    end
  else
    it "does not change the job handlers" do
      expect(handlers).not_to include("StandardError")
      expect(mail_handlers).not_to include("ActiveJob::DeserializationError")
    end
  end
end
