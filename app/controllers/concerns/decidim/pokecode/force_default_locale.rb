# frozen_string_literal: true

module Decidim
    module Pokecode
        module ForceDefaultLocale
            extend ActiveSupport::Concern

            included do
                # Detects the locale priority: query string, user saved, session, browser
                def detect_locale
                    if params[:locale].present?
                        params[:locale]
                    elsif current_user && current_user.locale.present?
                        current_user.locale
                    elsif session[:user_locale].present?
                        session[:user_locale]
                    else
                        default_locale
                    end
                end
            end
        end
    end
end