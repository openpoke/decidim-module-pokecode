module Decidim
  module Pokecode
    module AssembliesPermissionsOverride
      extend ActiveSupport::Concern

      included do
        def user_can_read_private_users?
          return unless permission_action.subject == :space_private_user

          toggle_allow(user.admin? || can_manage_assembly?(role: :admin) || can_manage_assembly?(role: :collaborator))
        end
      end
    end
  end
end
