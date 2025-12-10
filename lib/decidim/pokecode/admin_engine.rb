# frozen_string_literal: true

module Decidim
  module Pokecode
    # This is the engine that runs on the public interface of `Pokecode`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Pokecode::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      def load_seed
        nil
      end

      initializer "pokecode.admin_iframe" do |app|
        if Decidim::Pokecode.admin_iframe_enabled
          Decidim::Admin::Engine.routes do
            # authenticate :user, ->(u) { u.admin? } do
            get :iframe, to: "/decidim/pokecode/admin/iframe#index", as: :admin_iframe
            # end
          end
          Decidim.menu :admin_menu do |menu|
            menu.add_item :custom_iframe,
                          ENV.fetch("ADMIN_IFRAME_TITLE", "Web Stats"),
                          Decidim::Admin::Engine.routes.url_helpers.admin_iframe_path,
                          icon_name: "bar-chart-2-line",
                          position: 10
          end
          Rails.logger.info "[Decidim::Pokecode] Admin Iframe enabled."
        else
          Rails.logger.info "[Decidim::Pokecode] Admin Iframe disabled."
        end
      end
    end
  end
end
