# config/initializers/devise.rb
Devise.setup do |config|
  # ==> JWT Configuration (Kept from your original file)
  config.jwt do |jwt|
    jwt.secret = ENV["DEVISE_JWT_SECRET_KEY"]

    # Ensure all paths needing a new token are included here (e.g., sign_in and Google callback)
    jwt.dispatch_requests = [
      [ "POST", %r{^/api/v1/users/sign_in$} ],
      [ "POST", %r{^/api/v1/users$} ], # Assuming registration needs a token dispatch
      [ "POST", %r{^/api/v1/users/auth/google_oauth2/callback$} ],
      # OAuth callbacks are typically GET requests from providers. Ensure we
      # dispatch a JWT for GET callbacks as well so `request.env['warden-jwt_auth.token']`
      # is available in the Omniauth callbacks controller.
      [ "GET", %r{^/api/v1/users/auth/google_oauth2/callback$} ]
    ]

    jwt.revocation_requests = [
      [ "DELETE", %r{^/api/v1/users/sign_out$} ]
    ]
    jwt.expiration_time = 1.day.to_i
  end

  # =========================================================================
  # ==> OmniAuth and API-Specific Configurations
  # =========================================================================

  # Configure the Omniauth Provider (Google OAuth2)
  # This section automatically inserts the OmniAuth middleware (OmniAuth::Builder).
  config.omniauth :google_oauth2,
    ENV["GOOGLE_CLIENT_ID"],
    ENV["GOOGLE_CLIENT_SECRET"],
    {
      scope: "email,profile",
      prompt: "select_account",
      image_aspect_ratio: "square",
      image_size: 50
    }

  # In development, enable the OmniAuth developer strategy to allow testing
  # the full OAuth callback flow without contacting external providers.
  # Usage: visit /api/v1/users/auth/developer?role=seller to simulate Google
  # returning a successful callback. Only enabled in non-production.
  if Rails.env.development?
    begin
      require "omniauth/strategies/developer"
      config.omniauth :developer
    rescue LoadError => e
      Rails.logger.warn "OmniAuth developer strategy not available: #{e.message}"
    end
  end

  # Configure the session store (Moved from your working project's file)
  # This is CRITICAL for cross-origin API calls to work with cookies/sessions.
  # Use :lax in development so top-level OAuth redirects will include the
  # session cookie. Use :none in production for cross-site frontends.
  session_same_site = Rails.env.production? ? :none : :lax
  Rails.application.config.session_store :cookie_store,
    key: "_kitunga_session",
    secure: Rails.env.production?,
    same_site: session_same_site

  # Configure cookies for the :rememberable module (Matching your working project)
  config.rememberable_options = {
    secure: Rails.env.production?,
    same_site: session_same_site
  }

  # Skip session storage for basic HTTP auth to ensure tokens are used
  config.skip_session_storage = [ :http_auth ]

  # Use Active Record as the ORM
  require "devise/orm/active_record"

  # Configure default settings (Keep only the ones you've modified or need)
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.reconfirmable = true
  config.password_length = 6..128
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
  config.scoped_views = true

  # Hotwire/Turbo defaults (Good practice for modern Rails)
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

  # Prevents Devise from assuming we need HTML views for redirects/errors
  config.navigational_formats = []

  # You can keep other Devise options if you need them (e.g., confirmation_keys, timeout_in, etc.)
end
