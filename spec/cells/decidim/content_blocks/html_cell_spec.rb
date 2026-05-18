# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::HtmlCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :html, scope_name: :homepage, settings:) }
  let(:settings) { { "html_content_en" => html_content } }

  controller Decidim::PagesController

  context "when UNSAFE_HTML_BLOCKS is enabled" do
    before { allow(Decidim::Pokecode).to receive(:unsafe_html_blocks).and_return(true) }

    context "with safe HTML" do
      let(:html_content) { "<p>Gotta catch <strong>world</strong></p>" }

      it "renders the HTML tags" do
        expect(subject).to have_css("p")
        expect(subject).to have_css("strong", text: "world")
      end
    end

    context "with a script tag" do
      let(:html_content) { '<p>Gotta catch me</p><script>alert("xss")</script>' }

      it "renders the script tag unfiltered" do
        expect(subject.to_s).to include("<script>")
      end
    end
  end

  context "when UNSAFE_HTML_BLOCKS is disabled" do
    before { allow(Decidim::Pokecode).to receive(:unsafe_html_blocks).and_return(false) }

    context "with a script tag" do
      let(:html_content) { '<p>Gotta catch me</p><script>alert("xss")</script>' }

      it "strips the script tag" do
        expect(subject).to have_text("Gotta catch me")
        expect(subject.to_s).not_to include("<script>")
      end
    end

    context "with an event handler attribute" do
      let(:html_content) { '<p onmouseover="alert(1)">Gotta catch me</p>' }

      it "strips the event handler" do
        expect(subject).to have_text("Gotta catch me")
        expect(subject.to_s).not_to include("onmouseover")
      end
    end
  end
end
