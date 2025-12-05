# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/pokecode_footer_examples"

describe "Homepage" do
  let!(:organization) { create(:organization) }
  let!(:assembly) { create(:assembly, :published, organization:) }
  let!(:user) { create(:user, :admin, organization:) }

  before do
    switch_to_host(organization.host)
    sign_in(user)
    visit decidim.root_path
  end