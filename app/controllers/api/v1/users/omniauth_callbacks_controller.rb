module Api
  module V1
    module Users
      class OmniauthCallbacksController < Devise::OmniauthCallbacksController
        # Expect JSON-based flow where frontend handles redirection
        def google_oauth2
            @user = User.from_omniauth(request.env['omniauth.auth'])

            if @user.persisted?
              sign_in @user
              token = request.env['warden-jwt_auth.token']
              respond_to do |format|
                format.json { render json: { message: 'Signed in with Google', user: @user, access_token: token } }
                format.html { render layout: false, locals: { access_token: token, user: @user } }
              end
            else
              respond_to do |format|
                format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity }
                format.html { render plain: 'Authentication failed', status: :unauthorized }
              end
            end
        end

        def failure
          render json: { error: 'Omniauth failure' }, status: :unauthorized
        end
      end
    end
  end
end
