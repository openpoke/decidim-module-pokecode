# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe BlockUserMailer do
    let(:user) { create(:user) }
    let(:mail) { described_class.notify(user, token) }
    let(:token) { SecureRandom.base58(24) }

    it_behaves_like "conditionally applies white background to email"
  end

  describe NotificationMailer do
    let(:user) { create(:user) }
    let(:resource) { user }
    let(:event_class_name) { "Decidim::ProfileUpdatedEvent" }
    let(:event) { "decidim.events.users.profile_updated" }
    let(:event_instance) do
      event_class_name.constantize.new(resource:, event_name: event, user:, user_role: :follower)
    end

    let(:mail) { described_class.event_received(event, event_class_name, resource, user, :follower, {}) }

    it_behaves_like "conditionally applies white background to email"
  end
end
