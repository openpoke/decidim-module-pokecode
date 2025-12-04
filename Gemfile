# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

DECIDIM_VERSION = "0.30.3"

gem "decidim", DECIDIM_VERSION
gem "decidim-pokecode", path: "."
# gem "decidim-conferences", DECIDIM_VERSION
# gem "decidim-initiatives", DECIDIM_VERSION
# gem "decidim-templates", DECIDIM_VERSION

gem "bootsnap", "~> 1.4"

gem "puma", ">= 6.3.1"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "decidim-dev", DECIDIM_VERSION

  gem "brakeman"
end

group :development do
  gem "letter_opener_web"
  gem "listen", "~> 3.1"
  gem "web-console"
end
