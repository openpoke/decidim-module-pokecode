# frozen_string_literal: true

require "spec_helper"

describe "Homepage" do
  let!(:organization) { create(:organization) }

  before do
    switch_to_host(organization.host)
  end

  context "when footer is enabled" do
    before do
      allow(Decidim::Pokecode).to receive(:pokecode_footer_enabled).and_return(true)
      visit decidim.root_path
    end

    it "includes custom logos" do
      expect(page).to have_css(".main-footer__down")

      within ".mini-footer__content" do
        expect(page).to have_css(".footer-logos")
        expect(page).to have_link("PokeCode - Decidim Makers")
        expect(page).to have_link("Decidim")
      end
    end
  end

  context "when footer is not enabled" do
    before do
      allow(Decidim::Pokecode).to receive(:pokecode_footer_enabled).and_return(false)
      visit decidim.root_path
    end

    it "does not include custom logos" do
      within ".mini-footer__content" do
        expect(page).to have_no_css(".footer-logos")
        expect(page).to have_no_link("PokeCode - Decidim Makers")
      end
    end
  end

  context "when header" do
    before do
      visit decidim.root_path
    end

    it "includes additional language chooser" do
      within ".main-bar__links-desktop" do
        expect(page).to have_css(".main-header__language-container")
      end
    end
  end
end
