module Api
  module V1
    module Users
      class ConfirmationsController < Devise::ConfirmationsController
        respond_to :json

        def create
          self.resource = resource_class.send_confirmation_instructions(resource_params)
          if successfully_sent?(resource)
            render json: { message: 'Confirmation instructions sent.' }
          else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def show
          self.resource = resource_class.confirm_by_token(params[:confirmation_token])
          if resource.errors.empty?
            render json: { message: 'Account confirmed.' }
          else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
