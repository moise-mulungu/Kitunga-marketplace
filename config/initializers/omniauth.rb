# config/initializers/omniauth.rb
# Allow GET requests for OmniAuth authorization in addition to POST.
# NOTE: OmniAuth 2.0 defaults to POST for auth requests to reduce CSRF risks.
# Prefer initiating auth via a top-level navigation (window.location) from the
# frontend so cookies and redirect flows work naturally. Enabling GET is
# provided as a compatibility option for certain flows, but it reduces CSRF
# protection and should be used carefully.

OmniAuth.config.allowed_request_methods = [:get, :post]
# Silence the omniauth GET request warning introduced in OmniAuth 2.x
OmniAuth.config.silence_get_warning = true
