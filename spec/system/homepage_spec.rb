# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/pokecode_footer_examples"

describe "Homepage" do
  let!(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim.root_path
  end

  if Decidim::Pokecode.pokecode_footer_enabled
    it_behaves_like "footer is enabled"
  else
    it_behaves_like "footer is disabled"
  end

  if Decidim::Pokecode.language_menu_enabled
    it "includes additional language chooser" do
      within ".main-bar__links-desktop" do
        expect(page).to have_css(".main-header__language-container")
      end
    end
  else
    it "does not include additional language chooser" do
      within ".main-bar__links-desktop" do
        expect(page).to have_no_css(".main-header__language-container")
      end
    end
  end
end
