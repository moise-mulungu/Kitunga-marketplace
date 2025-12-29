class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    if verify_recaptcha
      user = User.new(sign_up_params)
      if user.save
        # Generate OTP and send SMS
        otp = rand(100000..999999).to_s
        user.update(otp_code: otp)
        TwilioService.send_otp(user.phone, otp)

        # Do not confirm yet, wait for phone verification
        response_body = {
          message: "Sign up successful. Please verify your phone number.",
          user: {
            id: user.id,
            full_name: user.full_name,
            email: user.email,
            role: user.role,
            business_name: user.business_name,
            category: user.category,
            address: user.address,
            phone: user.phone
          },
          requires_phone_verification: true
        }

        render json: response_body, status: :created
      else
        render json: { status: "error", errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: 'reCAPTCHA verification failed' }, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role, :full_name, :business_name, :category, :address, :phone)
  end
end
