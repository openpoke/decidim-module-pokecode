# frozen_string_literal: true

if Decidim::Pokecode.language_menu_enabled
  Deface::Override.new(:virtual_path => "layouts/decidim/header/_main",
                       :name => "language-menu-in-header",
                       :insert_top => ".main-bar__links-desktop",
                       :partial => "decidim/pokecode/language_menu")
end
