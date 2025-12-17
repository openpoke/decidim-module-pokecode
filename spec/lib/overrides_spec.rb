# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      "/app/views/layouts/decidim/header/_main.html.erb" => "a090eeca739613446d2eab8f4de513b1",
      "/lib/tasks/decidim_tasks.rake" => "24289c09b9dab157eefe2aa366a4222b"
    }
  },
  {
    package: "decidim-assemblies",
    files: {
      "/app/models/decidim/assembly.rb" => "8347a13aa324c6dce4528829f06119e3",
      "/app/permissions/decidim/assemblies/permissions.rb" => "f26397a30c34eeb60af141b8ef0eb1bb"
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
