# frozen_string_literal: true

Deface::Override.new(:virtual_path => "layouts/decidim/footer/_mini",
                     :name => "mini-footer",
                     :surround => ".mini-footer__content",
                     :partial => "pokecode/mini_footer")
