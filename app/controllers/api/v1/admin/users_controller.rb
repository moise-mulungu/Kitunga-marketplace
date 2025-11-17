module Api
  module V1
    module Admin
      class UsersController < Api::V1::BaseController
        before_action :authenticate_user!
        before_action :require_admin!

        def index
          users = User.all
          render json: users, status: :ok
        end

        # GET /api/v1/admin/users/:id
        def show
          user = User.find(params[:id])
          render json: user, status: :ok
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Not found' }, status: :not_found
        end

        def deactivate
          user = User.find(params[:id])
          if protect_owner?(user)
            return render json: { error: 'Cannot modify owner admin' }, status: :forbidden
          end

          user.update(active: false)
          render json: { success: true }, status: :ok
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Not found' }, status: :not_found
        end

        # PUT /api/v1/admin/users/:id/reactivate
        def reactivate
          user = User.find(params[:id])
          if protect_owner?(user)
            return render json: { error: 'Cannot modify owner admin' }, status: :forbidden
          end

          user.update(active: true)
          render json: { success: true }, status: :ok
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Not found' }, status: :not_found
        end

        # PATCH /api/v1/admin/users/:id/update
        # Accepts { role: 'seller'|'customer', active: true|false }
        def update
          user = User.find(params[:id])
          if protect_owner?(user)
            return render json: { error: 'Cannot modify owner admin' }, status: :forbidden
          end

          permitted = params.permit(:role, :active)
          if permitted[:role].present?
            # Only allow known roles
            unless %w[customer seller].include?(permitted[:role])
              return render json: { error: 'Invalid role' }, status: :unprocessable_entity
            end
            user.role = permitted[:role]
          end
          user.active = permitted[:active] unless permitted[:active].nil?

          if user.save
            render json: { success: true, user: user }, status: :ok
          else
            render json: { error: user.errors.full_messages }, status: :unprocessable_entity
          end
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Not found' }, status: :not_found
        end

        private

        def protect_owner?(user)
          user.email.present? && user.email.downcase == 'moisemlg90@gmail.com'
        end
      end
    end
  end
end
