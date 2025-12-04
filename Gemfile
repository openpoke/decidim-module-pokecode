# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "0.30.4"
# Inside the development app, the relative require has to be one level up, as
# the Gemfile is copied to the development_app folder (almost) as is.
base_path = ""
base_path = "../" if File.basename(__dir__) == "development_app"
require_relative "#{base_path}lib/decidim/pokecode/version"

gem "decidim", DECIDIM_VERSION
gem "decidim-pokecode", path: "."

gem "bootsnap"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION
  gem "faker"

  gem "brakeman"
end

group :development do
  gem "letter_opener_web"
  gem "web-console"
end
