# frozen_string_literal: true

require "spec_helper"

module Decidim::Pokecode
  describe ForceDefaultLocale do
    let(:controller_class) do
      Class.new(Decidim::ApplicationController) do
        include Decidim::Pokecode::ForceDefaultLocale
      end
    end
    let(:controller) { controller_class.new }

    before do
      allow(controller).to receive(:params).and_return({})
      allow(controller).to receive(:current_user).and_return(nil)
      allow(controller).to receive(:session).and_return({})
      allow(controller).to receive(:default_locale).and_return(:en)
    end

    describe "#detect_locale" do
      it "uses the requested locale when present" do
        allow(controller).to receive(:params).and_return(locale: :ca)
        allow(controller).to receive(:current_user).and_return(double(locale: :fr))
        allow(controller).to receive(:session).and_return(user_locale: :es)

        expect(controller.detect_locale).to eq(:ca)
      end

      it "uses the current user's saved locale when present" do
        allow(controller).to receive(:current_user).and_return(double(locale: :ca))

        expect(controller.detect_locale).to eq(:ca)
      end

      it "uses the session locale when present" do
        allow(controller).to receive(:session).and_return(user_locale: :ca)

        expect(controller.detect_locale).to eq(:ca)
      end

      it "falls back to the default locale instead of the browser locale" do
        allow(controller).to receive(:extract_locale_from_accept_language_header).and_return(:fr)

        expect(controller.detect_locale).to eq(:en)
      end
    end

    describe "the inherited locale detection" do
      let(:controller_class) do
        Class.new(ApplicationController) do
          include Decidim::LocaleSwitcher
        end
      end

      it "uses the browser locale when no other locale is set" do
        allow(controller).to receive(:extract_locale_from_accept_language_header).and_return(:fr)

        expect(controller.detect_locale).to eq(:fr)
      end
    end
  end
end
