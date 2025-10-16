module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            render json: { message: 'Signed up successfully.', user: resource }, status: :created
          else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def respond_to_on_destroy
          head :no_content
        end

        # Permit extra params
        def sign_up_params
          params.require(:user).permit(:full_name, :email, :password, :password_confirmation, :role, :business_name, :category, :address, :phone)
        end

        def account_update_params
          params.require(:user).permit(:full_name, :email, :password, :password_confirmation, :current_password, :business_name, :category, :address, :phone)
        end
      end
    end
  end
end
