# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HtmlCell < Decidim::ViewModel
      def block_id
        "html-block-#{model.manifest_name.parameterize.gsub("_", "-")}"
      end

      def html_content
        if Decidim::Pokecode.unsafe_html_blocks
          translated_attribute(model.settings.html_content).html_safe
        else
          decidim_sanitize_editor_admin(translated_attribute(model.settings.html_content))
        end
      end
    end
  end
end
