# app/controllers/api/v1/users/sessions_controller.rb
module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        # Skip CSRF for API
        # skip_before_action :verify_authenticity_token
        # Prevent Devise redirect hooks
        skip_before_action :require_no_authentication, only: [:create]
        respond_to :json

        # POST /api/v1/users/sign_in
        def create
          email = params.dig(:user, :email)
          password = params.dig(:user, :password)

          Rails.logger.info "LOGIN DEBUG email=#{email.inspect} password=#{password.inspect}"

          user = User.find_for_database_authentication(email: email)

          # Case 1: user exists but not confirmed yet
          if user && !user.active_for_authentication?
            return render json: { errors: ['Please confirm your email before logging in.'] }, status: :unauthorized
          end

          # Case 2: valid credentials
          if user&.valid_password?(password)
            token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first

            render json: {
              message: 'Login successful',
              token: token,
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
            }, status: :ok
          else
            # Case 3: invalid email or password
            render json: { errors: ['Invalid email or password'] }, status: :unauthorized
          end
        end


        # DELETE /api/v1/users/sign_out
        def destroy
          # Invalidate JWT: try to read the token from Authorization header or
          # from Warden env and add its jti to the JwtDenylist so it cannot be reused.
          token = nil
          auth_header = request.headers['Authorization']
          token = auth_header.split(' ').last if auth_header.present?
          token ||= request.env['warden-jwt_auth.token']

          if token.present?
            begin
              payload = JWT.decode(token, ENV['DEVISE_JWT_SECRET_KEY'], true, { algorithm: 'HS256', verify_expiration: false }).first
              JwtDenylist.find_or_create_by!(jti: payload['jti']) do |d|
                d.exp = Time.at(payload['exp']) if payload['exp']
              end
            rescue StandardError => e
              Rails.logger.warn "Failed to revoke token on sign_out: #{e.class} - #{e.message}"
            end
          end

          sign_out(current_user) if current_user
          head :no_content
        end

        private

        # Prevent Devise from redirecting for JSON API
        def respond_with(resource, _opts = {})
          render json: { message: 'Login successful', user: resource }, status: :ok
        end

        def respond_to_on_destroy
          head :no_content
        end
      end
    end
  end
end
