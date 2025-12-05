# frozen_string_literal: true

if Decidim::Pokecode.pokecode_footer_enabled
  Deface::Override.new(:virtual_path => "layouts/decidim/footer/_mini",
                       :name => "mini-footer",
                       :replace => ".mini-footer__content",
                       :partial => "decidim/pokecode/mini_footer")
end
