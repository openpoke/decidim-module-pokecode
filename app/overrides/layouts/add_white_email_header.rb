# frozen_string_literal: true

if Decidim::Pokecode.email_white_header_enabled
  Deface::Override.new(:virtual_path => "layouts/decidim/mailer",
                       :name => "mailer-header",
                       :insert_after => "erb[loud]:contains('stylesheet_pack_tag')",
                       :partial => "decidim/pokecode/email_header")

  Deface::Override.new(:virtual_path => "layouts/decidim/newsletter_base",
                       :name => "newsletter-mailer-header",
                       :insert_after => "erb[loud]:contains('stylesheet_pack_tag')",
                       :partial => "decidim/pokecode/email_header")
end
