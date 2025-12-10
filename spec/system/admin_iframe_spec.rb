# frozen_string_literal: true

require "spec_helper"

describe "Admin" do
  let(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization:) }
  let!(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    allow(Rails.application).to \
      receive(:env_config).with(no_args).and_wrap_original do |m, *|
      m.call.merge(
        "action_dispatch.show_exceptions" => true,
        "action_dispatch.show_detailed_exceptions" => false
      )
    end
    switch_to_host(organization.host)
  end

  if Decidim::Pokecode.admin_iframe_enabled
    it "allows access to /admin/iframe for admin users" do
      login_as admin, scope: :user
      visit "/admin/iframe"
      expect(page).to have_current_path("/admin/iframe")
    end

    it "denies access to /admin/iframe for non-admin users" do
      login_as user, scope: :user
      allow(Capybara).to receive(:raise_server_errors).and_return(false)
      visit "/admin/iframe"
      expect(page).to have_content("The page you are looking for cannot be found")
    end

    it "denies access to /admin/iframe for unauthenticated users" do
      visit "/admin/iframe"
      expect(page).to have_current_path("/users/sign_in")
    end
  else
    it "denies access to /admin/iframe for all users" do
      login_as admin, scope: :user
      visit "/admin/iframe"
      expect(page).to have_content("The page you are looking for cannot be found")
    end
  end
end
