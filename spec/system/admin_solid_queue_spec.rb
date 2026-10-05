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

  if Decidim::Pokecode.solid_queue_enabled
    it "mounts Solid Queue Web UI at /solid_queue for admin users" do
      login_as admin, scope: :user
      visit "/solid_queue"
      expect(page).to have_current_path("/solid_queue")
      expect(page).to have_content("Solid Queue Monitor")
    end

    it "denies access to /solid_queue for non-admin users" do
      login_as user, scope: :user
      allow(Capybara).to receive(:raise_server_errors).and_return(false)
      visit "/solid_queue"
      expect(page).to have_content("The page you are looking for cannot be found")
    end

    it "denies access to /solid_queue for unauthenticated users" do
      visit "/solid_queue"
      expect(page).to have_current_path("/#{I18n.locale}/users/sign_in")
    end

    it "does not mount Sidekiq Web UI" do
      login_as admin, scope: :user
      visit "/sidekiq"
      expect(page).to have_content("The page you are looking for cannot be found")
    end
  else
    it "denies access to /solid_queue for all users" do
      login_as admin, scope: :user
      visit "/solid_queue"
      expect(page).to have_content("The page you are looking for cannot be found")
    end
  end
end
