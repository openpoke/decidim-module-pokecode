# frozen_string_literal: true

module Decidim
  module Pokecode
    module JobRetries
      extend ActiveSupport::Concern

      included do
        retry_on StandardError, wait: :polynomially_longer, attempts: 10
        retry_on ActiveRecord::Deadlocked
        discard_on ActiveJob::DeserializationError
      end
    end
  end
end
