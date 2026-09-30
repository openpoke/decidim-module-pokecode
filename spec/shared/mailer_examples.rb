# frozen_string_literal: true

shared_examples "conditionally applies white background to email" do
  if Decidim::Pokecode.email_white_header_enabled
    it "delivers mail with white background" do
      expect(mail.to).to include(user.email)
      expect(mail.body.encoded).to include("background-color: #ffffff;")
    end
  else
    it "delivers mail with default background" do
      expect(mail.to).to include(user.email)
      expect(mail.body.encoded).not_to include("background-color: #ffffff;")
    end
  end
end
