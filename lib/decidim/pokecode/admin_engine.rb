# frozen_string_literal: true

module Decidim
  module Pokecode
    # This is the engine that runs on the public interface of `Pokecode`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Pokecode::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :Pokecode do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "Pokecode#index"
      end

      def load_seed
        nil
      end
    end
  end
end
