module Api
  module V1
    module Admin
      class PaymentsController < Api::V1::BaseController
        before_action :authenticate_user!
        before_action :require_admin!

        def index
          payments = Payment.all.includes(:order)
          render json: payments
        end

        def show
          payment = Payment.find(params[:id])
          render json: payment, include: [:order]
        end
      end
    end
  end
end