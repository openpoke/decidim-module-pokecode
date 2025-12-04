# frozen_string_literal: true

require "spec_helper"

describe "Homepage" do
  let!(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
    visit decidim_admin.root_path
  end

  context "when footer" do
    it "includes custom logos" do
      expect(page).to have_css(".main-footer__down")

      within ".mini-footer__content" do
        expect(page).to have_css(".footer-logos")
        expect(page).to have_link("PokeCode - Decidim Makers")
        expect(page).to have_link("Decidim")
      end
    end
  end

  context "when header" do
    it "includes additional language chooser" do
      within ".main-bar__links-desktop" do
        expect(page).to have_css(".main-header__language-container")
      end
    end
  end
end
