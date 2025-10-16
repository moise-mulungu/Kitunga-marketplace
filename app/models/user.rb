class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable
  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable,
    :confirmable,
    :jwt_authenticatable,
    :omniauthable, omniauth_providers: %i[google_oauth2],
    jwt_revocation_strategy: JwtDenylist

  # Two-factor (TOTP) helper
  include Devise::TwoFactorable if defined?(Devise::TwoFactorable)

  has_many :products, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :payments, through: :orders

  enum :role, { customer: "customer", seller: "seller", admin: "admin" }

  validates :full_name, :email, presence: true
  validates :email, uniqueness: true

  def seller?
    role == "seller"
  end

  def admin?
    role == "admin"
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.find_by(email: data['email'])

    unless user
      user = User.create(
        full_name: data['name'],
        email: data['email'],
        password: Devise.friendly_token[0, 20],
        confirmed_at: Time.current
      )
    end
    user
  end

  # Two-factor helpers (TOTP)
  def generate_totp_secret
    self.otp_secret ||= ROTP::Base32.random_base32
    save(validate: false)
    otp_secret
  end

  def provisioning_uri(issuer: 'Kitunga')
    return nil unless otp_secret
    label = "#{issuer}:#{email}"
    ROTP::TOTP.new(otp_secret).provisioning_uri(label, issuer: issuer)
  end

  def verify_totp(code)
    return false unless otp_secret
    totp = ROTP::TOTP.new(otp_secret)
    totp.verify(code, drift_behind: 30)
  end
end
