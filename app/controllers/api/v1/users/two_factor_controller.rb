module Api
  module V1
    module Users
      class TwoFactorController < ApplicationController
        before_action :authenticate_user!

        # GET /api/v1/users/two_factor/provision
        # returns provisioning URI and secret (frontend should render QR)
        def provision
          current_user.generate_totp_secret unless current_user.otp_secret.present?
          render json: { otp_secret: current_user.otp_secret, provisioning_uri: current_user.provisioning_uri }
        end

        # POST /api/v1/users/two_factor/confirm
        # body: { code: '123456' }
        # verifies code and returns success but does not enable 2fa
        def confirm
          if current_user.verify_totp(params[:code])
            render json: { ok: true }
          else
            render json: { ok: false }, status: :unprocessable_entity
          end
        end

        # POST /api/v1/users/two_factor/enable
        # body: { code: '123456' }
        # verifies and enables 2fa for current_user
        def enable
          if current_user.verify_totp(params[:code])
            current_user.update(otp_required_for_login: true)
            render json: { enabled: true }
          else
            render json: { enabled: false }, status: :unprocessable_entity
          end
        end

        # POST /api/v1/users/two_factor/disable
        # body: { code: '123456' }
        def disable
          if current_user.verify_totp(params[:code])
            current_user.update(otp_required_for_login: false, otp_secret: nil)
            render json: { disabled: true }
          else
            render json: { disabled: false }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
