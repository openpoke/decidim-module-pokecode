# frozen_string_literal: true

module Decidim
  module Pokecode
    module AssembliesPermissionsOverride
      extend ActiveSupport::Concern

      included do
        def user_can_read_members?
          return false unless permission_action.subject == :space_member

          disallow!
        end
      end
    end
  end
end
