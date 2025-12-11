# frozen_string_literal: true

module Decidim
  module Pokecode
    module S3ObjectOverride
      extend ActiveSupport::Concern

      # AWS public_url can generate public url if the parameter virtual_host: true
      # However it only works for AWS as you have to name the bucket like a domain name in order to work
      # Other providers let you create CDN that have nothing to do with the bucket name
      included do
        def public_url(options = {})
          bucket_url = Decidim::Pokecode.aws_cdn_host.presence || bucket.url(options)
          url = URI.parse(bucket_url)
          url.path += "/" unless url.path[-1] == "/"
          url.path += key.gsub(%r{[^/]+}) { |s| Seahorse::Util.uri_escape(s) }
          url.to_s
        end
      end
    end
  end
end
