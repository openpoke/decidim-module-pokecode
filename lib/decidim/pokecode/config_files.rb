# frozen_string_literal: true

module Decidim
  module Pokecode
    class << self
      # Returns a hash with the configuration files to be copied to the host application
      # Format:
      #  { "path/to/file" => [ "lines to be checked not to exist" ] }
      attr_accessor :config_files
    end

    Pokecode.config_files = {}

    if Pokecode.semantic_logger_enabled
      Pokecode.config_files["config/puma.rb"] = [
        "SemanticLogger.reopen"
      ]
    end
  end
end
