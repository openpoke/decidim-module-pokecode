# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/mailer_examples"

module Decidim
  describe NewsletterMailer do
    let(:user) { create(:user, organization:) }
    let(:organization) { create(:organization) }

    let(:newsletter) { create(:newsletter, organization:) }
    let(:mail) { described_class.newsletter(user, newsletter) }

    it_behaves_like "conditionally applies white background to email"
  end
end
