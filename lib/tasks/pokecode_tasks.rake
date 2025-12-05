# frozen_string_literal: true

require "decidim/pokecode/config_files"

namespace :pokecode do
  desc "Copies configuration files to the host application."
  task :copy_config_files do
    Decidim::Pokecode.config_files.each do |path, checks|
      source_path = Decidim::Pokecode::Engine.root.join("files/#{path}")
      full_path = Rails.root.join(path)
      next unless File.exist?(source_path)

      puts "Checking #{full_path}"

      content = File.exist?(full_path) ? File.read(full_path) : ""
      if checks.all? { |line| content.include?(line) }
        puts "  - Skipped (meets all conditions)"
        next
      else
        puts "  - Copying configuration file"
        FileUtils.cp(source_path, full_path)
      end
    end
  end
end
