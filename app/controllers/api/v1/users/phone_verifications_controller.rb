class Api::V1::Users::PhoneVerificationsController < ApplicationController
  def create
    otp = params[:otp]
    user = User.find_by(phone: params[:phone])

    if user && user.otp_code == otp
      user.update(phone_verified: true, confirmed_at: Time.current)
      user.clear_otp
      render json: { message: 'Phone verified successfully' }, status: :ok
    else
      render json: { error: 'Invalid OTP' }, status: :unprocessable_entity
    end
  end

  def resend
    user = User.find_by(phone: params[:phone])
    if user
      otp = generate_otp
      user.update(otp_code: otp)
      TwilioService.send_otp(user.phone, otp)
      render json: { message: 'OTP sent' }, status: :ok
    else
      render json: { error: 'User not found' }, status: :not_found
    end
  end

  private

  def generate_otp
    rand(100000..999999).to_s
  end
end