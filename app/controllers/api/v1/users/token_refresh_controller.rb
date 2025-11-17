module Api
  module V1
    module Users
      class TokenRefreshController < Api::V1::BaseController
        # This endpoint accepts the current Bearer JWT in the Authorization header,
        # validates it (ensures it's not revoked), then issues a fresh JWT and
        # revokes the old token by writing its jti to the JwtDenylist table.

        # POST /api/v1/users/refresh
        def create
          auth_header = request.headers['Authorization']
          unless auth_header.present? && auth_header.start_with?('Bearer ')
            return render json: { error: 'Missing token' }, status: :unauthorized
          end

          token = auth_header.split(' ').last

          begin
            # Allow a small refresh window after token expiration (e.g., 7 days)
            refresh_window_seconds = 7.days.to_i

            # Decode without verifying expiration so we can check the exp manually
            payload = JWT.decode(token, ENV['DEVISE_JWT_SECRET_KEY'], true, { algorithm: 'HS256', verify_expiration: false }).first

            # Check denylist to ensure token wasn't revoked already
            if JwtDenylist.exists?(jti: payload['jti'])
              return render json: { error: 'Token revoked' }, status: :unauthorized
            end

            # Validate expiry manually: allow if now <= exp + refresh_window_seconds
            token_exp = payload['exp'].to_i
            if Time.now.to_i > token_exp + refresh_window_seconds
              return render json: { error: 'Refresh window expired' }, status: :unauthorized
            end

            # Find the user referenced by the token (Devise-JWT uses `sub` claim)
            user_id = payload['sub']
            user = User.find_by(id: user_id)
            return render json: { error: 'User not found' }, status: :unauthorized unless user

            # Revoke the old token by recording its jti and expiry (if not already present)
            begin
              JwtDenylist.find_or_create_by!(jti: payload['jti']) do |d|
                d.exp = Time.at(payload['exp'])
              end
            rescue StandardError => e
              Rails.logger.warn "Failed to add old token to denylist: #{e.message}"
            end

            # Issue a new token
            new_token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first

            render json: { message: 'Token refreshed', token: new_token }, status: :ok
          rescue JWT::DecodeError => e
            render json: { error: 'Invalid token', details: e.message }, status: :unauthorized
          rescue StandardError => e
            Rails.logger.error "Token refresh error: #{e.class} - #{e.message}"
            render json: { error: 'Could not refresh token' }, status: :internal_server_error
          end
        end
      end
    end
  end
end
