# frozen_string_literal: true

require "spec_helper"

describe "MailInterceptor" do
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, :admin, organization:) }

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin.root_path
  end

  if Decidim::Pokecode.allowed_recipients_list.any?
    it "shows the staging warning in the admin dashboard" do
      expect(page).to have_content("Warning: Staging Environment")
      Decidim::Pokecode.allowed_recipients_list.each do |email|
        expect(page).to have_content(email)
      end
    end
  else
    it "does not show the staging warning in the admin dashboard" do
      expect(page).to have_no_content("Warning: Staging Environment")
    end
  end

  if Decidim::Pokecode.disable_invitations
    it "shows the invitations disabled warning in the admin dashboard" do
      expect(page).to have_content("Warning: Invitations Disabled")
      expect(page).to have_content("Invitation emails are currently disabled in this instance. Users will not receive invitation emails.")
    end
  else
    it "does not show the invitations disabled warning in the admin dashboard" do
      expect(page).to have_no_content("Warning: Invitations Disabled")
    end
  end
end
