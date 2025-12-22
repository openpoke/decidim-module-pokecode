# frozen_string_literal: true

if Decidim::Pokecode.allowed_recipients_list.any?
  Deface::Override.new(:virtual_path => "decidim/admin/dashboard/show",
                       :name => "add-staging-warning",
                       :insert_before => "div.content",
                       :partial => "decidim/pokecode/staging_warning")
end
