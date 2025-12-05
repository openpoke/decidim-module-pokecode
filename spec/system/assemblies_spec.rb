# frozen_string_literal: true

require "spec_helper"
require_relative "../shared/pokecode_footer_examples"

describe "Assemblies" do
  let!(:organization) { create(:organization) }
  let!(:assembly) { create(:assembly, :with_content_blocks, :published, blocks_manifests: [:main_data], organization:) }
  let!(:user) { create(:user, :confirmed, :admin, organization:) }
  let!(:participatory_space_private_user) do
    create(:participatory_space_private_user, :published, user:, privatable_to: assembly)
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_admin_assemblies.edit_assembly_path(slug: assembly.slug)
  end

  if Decidim::Pokecode.assembly_members_visible_enabled
    it "shows the private users page" do
      click_on "Members"
      expect(page).to have_current_path(decidim_admin_assemblies.participatory_space_private_users_path(assembly_slug: assembly.slug))
      expect(page).to have_content("Participatory space private participant")
      visit decidim_assemblies.assembly_path(slug: assembly.slug)
      click_on "Members"
      expect(page).to have_current_path(decidim_assemblies.assembly_participatory_space_private_users_path(assembly))
      expect(page).to have_content("Members")
    end
  else
    it "does not show the private users page" do
      expect(page).to have_no_content("Members")
      visit decidim_admin_assemblies.participatory_space_private_users_path(assembly_slug: assembly.slug)
      expect(page).to have_content("You are not authorized to perform this action.")
      visit decidim_assemblies.assembly_path(slug: assembly.slug)
      expect(page).to have_no_content("Members")
      visit decidim_assemblies.assembly_participatory_space_private_users_path(assembly)
      expect(page).to have_no_content("Members")
      expect(page).to have_content("About this assembly")
    end
  end
end
