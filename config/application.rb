require 'dotenv/load'
require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)

# config/application.rb
module KitungaMarket
  class Application < Rails::Application
    # ...
    config.api_only = true

    # Ensure cookie and session middleware are loaded before OmniAuth/Devise
    # middleware so OmniAuth has access to a session (required by
    # omniauth-rails_csrf_protection and the OAuth state handshake).
    # Insert cookies at the very top of the stack and the session store
    # immediately after it with appropriate cookie attributes to allow
    # cross-origin flows (frontend on a different port/domain).
    config.middleware.insert_before 0, ActionDispatch::Cookies
    # In development we prefer :lax (works with top-level GET navigations) while
    # in production we use :none so cross-site frontends can receive cookies.
    session_same_site = Rails.env.production? ? :none : :lax
    config.middleware.insert_after ActionDispatch::Cookies, ActionDispatch::Session::CookieStore,
      key: '_kitunga_session', secure: Rails.env.production?, same_site: session_same_site
    config.middleware.use ActionDispatch::Flash

    # Keep method override as the working app had it.
    config.middleware.use Rack::MethodOverride
  end
end