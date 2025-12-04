# frozen_string_literal: true

require "decidim/pokecode/config_files"

namespace :pokecode do
  desc "Copies configuration files to the host application."
  task :copy_config_files do
    Decidim::Pokecode.config_files.each do |path, checks|
      full_path = Rails.root.join(path)
      next unless File.exist?(full_path)

      puts "Checking #{full_path}"

      content = File.read(full_path)
      if checks.any? { |line| content.include?(line) }
        puts "  - Skipped (checks found)"
        next
      else
        puts "  - Copying configuration file"
        source_path = File.expand_path("../../#{path}", __dir__)
        FileUtils.cp(source_path, full_path)
      end
    end
  end
end
