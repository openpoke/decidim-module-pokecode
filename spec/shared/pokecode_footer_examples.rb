shared_examples "footer is enabled" do
  it "includes custom logos" do
    expect(page).to have_css(".main-footer__down")

    within ".mini-footer__content" do
      expect(page).to have_css(".footer-logos")
      expect(page).to have_link("PokeCode - Decidim Makers")
      expect(page).to have_link("Decidim")
    end
  end
end

shared_examples "footer is disabled" do
  it "does not include custom logos" do
    within ".mini-footer__content" do
      expect(page).to have_no_css(".footer-logos")
      expect(page).to have_no_link("PokeCode - Decidim Makers")
      expect(page).to have_link("Decidim")
    end
  end
end
