# frozen_string_literal: true

require "spec_helper"

# We make sure that the checksum of the file overriden is the same
# as the expected. If this test fails, it means that the overriden
# file should be updated to match any change/bug fix introduced in the core
checksums = [
  {
    package: "decidim-core",
    files: {
      "/app/views/layouts/decidim/header/_main.html.erb" => "2808459045fd14b7f8d689fbbd6dfa4e",
      "/app/models/decidim/notification.rb" => "4510aadea1546d3590a768eddf8a172c", # TODO: remove when fixed upstream
      "/lib/tasks/decidim_tasks.rake" => "c9e470d5857eae31fd477e668e0a6f9d",
      "/app/views/layouts/decidim/mailer.html.erb" => "6a08103c75e5db737a38cd365428a177",
      "/app/views/layouts/decidim/newsletter_base.html.erb" => "28111c73d348ec8d1cdc1180d3ff5d21",
      "/app/controllers/decidim/locales_controller.rb" => "8cdc1208b716ef843ab5da34d74ca9f7",
      "/app/cells/decidim/content_blocks/html_cell.rb" => "67df12cd1caefa3a8ddb7d340dcd057f"
    }
  },
  {
    package: "decidim-assemblies",
    files: {
      "/app/models/decidim/assembly.rb" => "27eaae12c695bcbfdb708f454dfda7c3",
      "/app/permissions/decidim/assemblies/permissions.rb" => "6d4578e770574c3d3e126e38ca97ce4a"
    }
  },
  {
    package: "decidim-admin",
    files: {
      "/app/views/decidim/admin/dashboard/show.html.erb" => "d3cdc308ae81042c6c2b0e68b71be444"
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
