# frozen_string_literal: true

# TODO: Remove when fixed upstream
module Decidim
  module Pokecode
    module NotificationOverride
      extend ActiveSupport::Concern

      included do
        # This is due to the bug in https://github.com/decidim/decidim/issues/15949
        def can_participate?(user)
          return resource.can_participate?(user) if resource.respond_to?(:can_participate?)

          true
        end
      end
    end
  end
end
