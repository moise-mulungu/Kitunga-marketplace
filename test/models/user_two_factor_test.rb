require 'test_helper'

class UserTwoFactorTest < ActiveSupport::TestCase
  test 'provisioning and verify totp' do
    user = users(:one) rescue User.create!(full_name: 'Test', email: "tf+#{SecureRandom.hex(4)}@example.com", password: 'password', confirmed_at: Time.current)
    secret = user.generate_totp_secret
    assert secret.present?

    uri = user.provisioning_uri(issuer: 'KitungaTest')
    assert uri.include?('otpauth://')

    totp = ROTP::TOTP.new(secret)
    code = totp.now
    assert user.verify_totp(code)
  end
end
