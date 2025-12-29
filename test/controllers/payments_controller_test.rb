class Api::V1::PaymentsController < Api::V1::BaseController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user!, except: [:verify, :webhook]

  require 'httparty'

  # POST /api/v1/payments
  def create
    order = Order.find(payment_params[:order_id])

    payload = {
      tx_ref: "kitunga-#{SecureRandom.hex(10)}",
      amount: order.total_amount,
      currency: "USD",
      redirect_url: "#{ENV['KITUNGA_MARKET_FRONTEND_URL']}/payment/callback",
      customer: {
        email: order.user.email,
        name: order.user.full_name
      }
    }

    response = HTTParty.post(
      "https://api.flutterwave.com/v3/payments",
      headers: { "Authorization" => "Bearer #{ENV['FLW_SECRET_KEY']}" },
      body: payload.to_json
    )

    unless response["status"] == "success"
      return render json: { error: response["message"] }, status: :bad_request
    end

    data = response["data"]

    payment = Payment.create!(
      order_id: order.id,
      payment_method: "flutterwave",
      amount: order.total_amount,
      transaction_id: payload[:tx_ref],
      status: "pending"
    )

    render json: {
      payment_link: data["link"],
      reference: payload[:tx_ref],
      payment_id: payment.id
    }
  end

  # POST /api/v1/payments/verify
  def verify
    reference = params[:reference]

    response = HTTParty.get(
      "https://api.flutterwave.com/v3/transactions/#{reference}/verify",
      headers: { "Authorization" => "Bearer #{ENV['FLW_SECRET_KEY']}" }
    )

    unless response["status"] == "success"
      return render json: { error: "Verification failed" }, status: :bad_request
    end

    payment = Payment.find_by(transaction_id: reference)
    return render json: { error: "Payment not found" }, status: :not_found unless payment

    order = payment.order
    data = response["data"]

    if data["status"] == "successful"
      payment.update!(status: "completed", paid_at: Time.current)
      order.update!(payment_status: "paid", status: "complete")
      render json: { message: "Payment confirmed", order: order }
    else
      payment.update!(status: "failed")
      order.update!(payment_status: "failed", status: "cancelled")
      render json: { error: "Payment failed" }
    end
  end

  # POST /api/v1/payments/webhook
  def webhook
    event = JSON.parse(request.body.read)
    tx_ref = event["data"]["tx_ref"]
    status = event["data"]["status"]

    payment = Payment.find_by(transaction_id: tx_ref)
    return head :ok unless payment

    order = payment.order

    if status == "successful"
      payment.update!(status: "completed", paid_at: Time.current)
      order.update!(payment_status: "paid", status: "complete")
    else
      payment.update!(status: "failed")
      order.update!(payment_status: "failed", status: "cancelled")
    end

    head :ok
  end

  private

  def payment_params
    params.require(:payment).permit(:order_id)
  end
end
