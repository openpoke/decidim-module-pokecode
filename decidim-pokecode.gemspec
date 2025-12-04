# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/pokecode/version"

Gem::Specification.new do |s|
  s.version = Decidim::Pokecode::VERSION
  s.authors = ["Ivan Vergés"]
  s.email = ["ivan@pokecode.net"]
  s.license = "AGPL-3.0-or-later"
  s.homepage = "https://decidim.org"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/openpoke/decidim-module-pokecode/issues",
    "source_code_uri" => "https://github.com/openpoke/decidim-module-pokecode"
  }
  s.required_ruby_version = "~> 3.3"

  s.name = "decidim-pokecode"
  s.summary = "A module for deploying and customizing Decidim applications by Pokecode."
  s.description = "Internal module for deploying and customizing Decidim applications by Pokecode."

  s.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(app/ config/ db/ lib/ LICENSE-AGPLv3.txt Rakefile README.md))
    end
  end

  s.add_dependency "decidim-core", Decidim::Pokecode::COMPAT_DECIDIM_VERSION
  s.add_dependency "deface", ">= 1.5"
  s.add_dependency "health_check"
  s.add_dependency "rails_semantic_logger"
  s.add_dependency "sidekiq"
  s.add_dependency "sidekiq-cron"
end
