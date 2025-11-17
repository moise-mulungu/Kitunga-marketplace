class Api::V1::UsersController < Api::V1::BaseController

  def index
    users = User.all
    users = users.where(role: 'seller') if params[:role] == 'seller'
    render json: users.as_json(methods: [:profile_image_url])
  end

  def sellers
    sellers = User.where(role: 'seller')
    render json: sellers
  end


  def show
    user = User.find(params[:id])
    render json: user.as_json(methods: [:profile_image_url])
  end

  # Return the currently authenticated user (requires Authorization header)
  def me
    if current_user
      render json: current_user.as_json(methods: [:profile_image_url])
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def create
    user = User.new(user_params)
    if user.save
      token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
      render json: { user: user, token: token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    user = User.find(params[:id])
    if user.update(user_params)
      render json: {
        status: 'ok',
        user: user.as_json(methods: [:profile_image_url])
      }
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    head :no_content
  end

  def setup
    user = current_user

    unless user.role == 'seller'
      return render json: { success: false, errors: ['Only sellers can complete setup'] }, status: :forbidden
    end

    if user.update(user_params.slice(:business_name, :category, :address, :phone))
      # Send confirmation email after setup if not already confirmed
      user.send_confirmation_instructions if user.confirmed_at.nil?

      render json: { success: true, message: 'Seller setup complete. Confirmation email sent.', user: user }
    else
      render json: { success: false, errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end


  private

  def user_params
    params.require(:user).permit(
      :full_name, :email, :password, :password_confirmation,
      :role, :business_name, :category, :address, :phone, :active, :avatar, :image_url, :otp_secret, :two_factor_enabled
    )
  end
end
