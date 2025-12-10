# frozen_string_literal: true

if Decidim::Pokecode.analytics_enabled
  Deface::Override.new(:virtual_path => "layouts/decidim/_head",
                       :name => "language-menu-in-header",
                       :insert_before => "erb[loud]:contains('render partial: \"layouts/decidim/head_extra\"')",
                       :partial => "decidim/pokecode/head_analytics")
end
