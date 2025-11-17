class Api::V1::Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    user = User.new(sign_up_params)
    if user.save
      # If the user is confirmed (e.g., OAuth flow), dispatch a JWT so frontend
      # can use it immediately. For email signups requiring confirmation, do
      # not issue a token — instruct the frontend to ask the user to confirm.
      response_body = {
        message: 'Sign up successful',
        user: {
          id: user.id,
          full_name: user.full_name,
          email: user.email,
          role: user.role,
          business_name: user.business_name,
          category: user.category,
          address: user.address,
          phone: user.phone
        }
      }

      if user.confirmed?
        token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
        response_body[:token] = token
      else
        response_body[:message] = 'Confirmation required. Please check your email for confirmation instructions.'
      end

      render json: response_body, status: :created
    else
      render json: { status: 'error', errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role, :full_name, :business_name, :category, :address, :phone)
  end
end
