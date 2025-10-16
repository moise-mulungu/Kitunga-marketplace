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
end
