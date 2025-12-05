module Decidim
  module Pokecode
    module AssemblyOverride
      extend ActiveSupport::Concern

      included do
        # This is a overwrite for Decidim::HasPrivateUsers.members_public_page?
        def members_public_page?
          participatory_space_private_users.published.any?
        end
      end
    end
  end
end
