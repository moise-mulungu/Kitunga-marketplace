module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        respond_to :json

        private

        def respond_with(resource, _opts = {})
          token = request.env['warden-jwt_auth.token']
          render json: { message: 'Signed in successfully.', user: resource, access_token: token }, status: :ok
        end

        def respond_to_on_destroy
          # Revoke handled by devise-jwt revocation_requests
          head :no_content
        end
      end
    end
  end
end
