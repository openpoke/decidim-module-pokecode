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
      "/app/models/decidim/notification.rb" => "4510aadea1546d3590a768eddf8a172c", # TODO: remove when fixed upstream
      "/lib/tasks/decidim_tasks.rake" => "24289c09b9dab157eefe2aa366a4222b",
      "/app/views/layouts/decidim/mailer.html.erb" => "6a08103c75e5db737a38cd365428a177",
      "/app/views/layouts/decidim/newsletter_base.html.erb" => "28111c73d348ec8d1cdc1180d3ff5d21",
      "/app/controllers/decidim/locales_controller.rb" => "59642cefd266b6648986ba6368ad75e8",
      "/app/cells/decidim/content_blocks/html_cell.rb" => "34a46115c08d31406760136271afb739"
    }
  },
  {
    package: "decidim-assemblies",
    files: {
      "/app/models/decidim/assembly.rb" => "0a821e89a6f470d1cf370fa7eb474236",
      "/app/permissions/decidim/assemblies/permissions.rb" => "f26397a30c34eeb60af141b8ef0eb1bb"
    }
  },
  {
    package: "decidim-admin",
    files: {
      "/app/views/decidim/admin/dashboard/show.html.erb" => "45558619f30212c2aa079e744c4be4ea"
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
