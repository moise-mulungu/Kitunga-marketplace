Recaptcha.configure do |config|
  config.site_key = ENV['KITUNGA_MARKET_RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['KITUNGA_MARKET_RECAPTCHA_SECRET_KEY']
end