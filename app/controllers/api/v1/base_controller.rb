module Api
  module V1
    class BaseController < ActionController::API
      before_action :authorize_request
      before_action :ensure_json_request

      attr_reader :current_user

      # Handle standard errors globally for cleaner API responses
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
      rescue_from ActionController::ParameterMissing, with: :render_bad_request
      rescue_from Pundit::NotAuthorizedError, with: :render_unauthorized if defined?(Pundit)
      rescue_from StandardError, with: :render_internal_server_error

      private

      # ✅ Require JSON headers for all API endpoints
      def ensure_json_request
        request.format = :json
      end

      # Attempt to authorize the request by decoding a JWT from the
      # Authorization header. This sets @current_user when a valid token
      # is present but does not by itself block access (controllers can
      # call `authenticate_user!` to require authentication).
      def authorize_request
        auth_header = request.headers["Authorization"]
        return unless auth_header.present?

        token = auth_header.split(" ").last
        return unless token

        begin
          # Use Warden's JWT user decoder to resolve the token to a User.
          user = Warden::JWTAuth::UserDecoder.new.call(token, :user, nil)
          @current_user = user
        rescue StandardError => e
          Rails.logger.debug "JWT decode error: #{e.class} - #{e.message}"
          @current_user = nil
        end
      end

      # Require a valid, authorized user for protected endpoints. This
      # mirrors Devise's `authenticate_user!` semantics for API controllers
      # that don't include Devise controller helpers.
      def authenticate_user!
        render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
      end

      # Require the current user to be an admin
      def require_admin!
        unless current_user&.admin?
          render json: { error: "Forbidden" }, status: :forbidden
        end
      end

      # ✅ Common error handlers
      def render_not_found(exception)
        render json: { error: "Record not found", details: exception.message }, status: :not_found
      end

      def render_unprocessable_entity(exception)
        render json: { error: "Unprocessable entity", details: exception.record.errors.full_messages }, status: :unprocessable_entity
      end

      def render_bad_request(exception)
        render json: { error: "Bad request", details: exception.message }, status: :bad_request
      end

      def render_unauthorized(exception = nil)
        render json: { error: "Unauthorized", details: exception&.message }, status: :unauthorized
      end

      def render_internal_server_error(exception)
        Rails.logger.error "🔥 #{exception.class} - #{exception.message}"
        Rails.logger.error exception.backtrace.join("\n") if exception.backtrace
        render json: { error: "Internal server error", details: exception.message }, status: :internal_server_error
      end
    end
  end
end
