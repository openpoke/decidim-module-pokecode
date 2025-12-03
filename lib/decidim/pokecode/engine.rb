# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Pokecode
    # This is the engine that runs on the public interface of Pokecode.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Pokecode

      routes do
        # Add engine routes here
        # resources :pokecode
        # root to: "pokecode#index"
      end

      initializer "pokecode.shakapacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
