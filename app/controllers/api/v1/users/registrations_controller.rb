module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json

        private

        def respond_with(resource = nil, _opts = {})
          resource ||= self.resource

          if resource&.persisted?
            if resource.role == "seller"
            resource.send_confirmation_instructions if resource.confirmed_at.nil?

            render json: {
              message: "Signup successful! Please confirm your email.",
              user: {
                id: resource.id,
                full_name: resource.full_name,
                email: resource.email,
                role: resource.role,
                confirmed_at: resource.confirmed_at
              }
            }, status: :created
            else
              # Customers confirm email immediately
              resource.send_confirmation_instructions
              render json: {
                message: "Customer signed up successfully. Please confirm your email.",
                user: {
                  id: resource.id,
                  full_name: resource.full_name,
                  email: resource.email,
                  role: resource.role,
                  confirmed_at: resource.confirmed_at
                }
              }, status: :created
            end
          else
            render json: { errors: resource ? resource.errors.full_messages : [ "Sign up failed" ] },
                   status: :unprocessable_entity
          end
        end

        def sign_up_params
          params.require(:user).permit(
            :full_name, :email, :password, :password_confirmation, :role,
            :business_name, :category, :address, :phone
          )
        end

        def account_update_params
          params.require(:user).permit(
            :full_name,
            :email,
            :password,
            :password_confirmation,
            :current_password,
            :business_name,
            :category,
            :address,
            :phone
          )
        end
      end
    end
  end
end
