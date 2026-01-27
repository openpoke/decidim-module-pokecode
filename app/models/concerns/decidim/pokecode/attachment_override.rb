# frozen_string_literal: true

module Decidim
  module Pokecode
    module AttachmentOverride
      extend ActiveSupport::Concern

      included do
        # This is due to the bug in https://github.com/decidim/decidim/issues/15949
        def can_participate?(user)
          return true unless attached_to
          return true unless attached_to.respond_to?(:can_participate?)

          attached_to.can_participate?(user)
        end
      end
    end
  end
end
