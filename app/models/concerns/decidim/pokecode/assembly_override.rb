# frozen_string_literal: true

module Decidim
  module Pokecode
    module AssemblyOverride
      extend ActiveSupport::Concern

      included do
        # This is a overwrite for Decidim::ParticipatorySpace::HasMembers.members_public_page?
        def members_public_page?
          false
        end
      end
    end
  end
end
