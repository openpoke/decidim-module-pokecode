# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      "/app/views/layouts/decidim/header/_main.html.erb" => "2cda0f82a0ac644c1ba89f84d5c60b97",
      "/lib/tasks/decidim_tasks.rake" => "9408028d3075c93e6eb2e94131c108d0"
    }
  },
  {
    package: "decidim-assemblies",
    files: {
      "/app/models/decidim/assembly.rb" => "f44461dcbc95371a00feb69077b61355",
      "/app/permissions/decidim/assemblies/permissions.rb" => "115853e2f3a2cef7904fb3d36504a47e"
    }
  },
  {
    package: "aws-sdk-s3",
    files: {
      "/lib/aws-sdk-s3/customizations/object.rb" => "916a7ede54078548dc78c4be9a8ae192"
    }
  }
]

describe "Overriden files", type: :view do
  checksums.each do |item|
    spec = Gem::Specification.find_by_name(item[:package])
    item[:files].each do |file, signature|
      it "#{spec.gem_dir}#{file} matches checksum" do
        expect(md5("#{spec.gem_dir}#{file}")).to eq(signature)
      end
    end
  end

  private

  def md5(file)
    Digest::MD5.hexdigest(File.read(file))
  end
end
