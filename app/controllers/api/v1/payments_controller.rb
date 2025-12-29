# app/controllers/api/v1/payments_controller.rb
class Api::V1::PaymentsController < Api::V1::BaseController
  before_action :authenticate_user!, except: [:index, :show, :verify, :webhook]
  # skip_before_action :verify_authenticity_token, only: [:webhook]

  # GET /api/v1/payments
  def index
    render json: Payment.all
  end

  # GET /api/v1/payments/:id
  def show
    render json: Payment.find(params[:id])
  end

  # POST /api/v1/payments
  # Initializes a Flutterwave checkout and returns a payment link
  def create
    order = Order.find(payment_params[:order_id])
    tx_ref = "order_#{order.id}_#{SecureRandom.hex(6)}"

    # If Flutterwave is NOT configured → run FAKE PAYMENT immediately
    if ENV['FLUTTERWAVE_SECRET_KEY'].blank?
      return fake_payment_success(order, tx_ref)
    end

    # Prepare real payment body
    body = {
      tx_ref: tx_ref,
      amount: order.total_amount.to_f,
      currency: "USD",
      redirect_url: "#{ENV['KITUNGA_MARKET_FRONTEND_URL']}/payment/callback",
      customer: {
        email: order.user&.email || "guest@example.com",
        name: order.user&.full_name || "Guest"
      },
      meta: {
        order_id: order.id,
        user_id: order.user&.id
      }
    }

    # Attempt REAL payment with Flutterwave
    response = HTTParty.post(
      "https://api.flutterwave.com/v3/payments",
      headers: {
        "Authorization" => "Bearer #{ENV['FLUTTERWAVE_SECRET_KEY']}",
        "Content-Type" => "application/json"
      },
      body: body.to_json
    )

    # If API fails → fallback to fake
    if !response || response["status"] != "success"
      return fake_payment_success(order, tx_ref)
    end

    # REAL PAYMENT succeeded
    data = response["data"]
    payment_link = data["link"] || data["authorization_url"] || data["checkout_url"]

    payment = Payment.create!(
      order_id: order.id,
      payment_method: "flutterwave",
      amount: order.total_amount,
      transaction_id: data["id"] || tx_ref,
      status: "pending",
      metadata: data
    )

    render json: {
      payment_url: payment_link,
      tx_ref: tx_ref,
      payment_id: payment.id,
      mode: "real"
    }, status: :created
  end


  # PATCH /api/v1/payments/:id
  def update
    payment = Payment.find(params[:id])
    if payment.update(payment_params)
      render json: payment
    else
      render json: { errors: payment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/payments/:id
  def destroy
    Payment.find(params[:id]).destroy
    head :no_content
  end

  # POST /api/v1/payments/verify (or GET, depending on your frontend)
  # Accepts param `id` (flutterwave transaction id) OR `tx_ref` (merchant ref)
  def verify
    tx_ref = params[:tx_ref]
    flw_id = params[:id]

    if flw_id.present?
      verify_url = "https://api.flutterwave.com/v3/transactions/#{flw_id}/verify"
    elsif tx_ref.present?
      # verify by merchant reference
      verify_url = "https://api.flutterwave.com/v3/transactions/verify_by_reference?tx_ref=#{URI.encode(tx_ref)}"
    else
      return render json: { error: "Missing id or tx_ref" }, status: :bad_request
    end

    response = HTTParty.get(
      verify_url,
      headers: { "Authorization" => "Bearer #{ENV['FLUTTERWAVE_SECRET_KEY']}" }
    )

    unless response && response["status"]
      return render json: { error: "Verification failed" }, status: :bad_request
    end

    data = response["data"]
    # find payment by stored transaction id or tx_ref meta
    payment = Payment.find_by(transaction_id: data["id"]) || Payment.find_by("metadata ->> 'tx_ref' = ?", data["tx_ref"]) || Payment.find_by(transaction_id: data["tx_ref"])

    return render json: { error: "Payment not found" }, status: :not_found unless payment

    order = payment.order

    if data["status"] == "successful" || data["status"] == "success"
      payment.update!(status: "completed", paid_at: Time.current)
      order.update!(payment_status: "paid", status: "complete")
      render json: { message: "Payment verified", order: order, data: data }
    else
      payment.update!(status: "failed")
      order.update!(payment_status: "failed", status: "cancelled")
      render json: { error: "Payment failed", data: data }, status: :payment_required
    end
  end

  # POST /api/v1/payments/webhook
  # Flutterwave sends `verif-hash` header if you set Secret Hash in dashboard
  def webhook
    # verify signature
    unless valid_flutterwave_webhook?
      return head :unauthorized
    end

    payload = JSON.parse(request.body.read) rescue {}
    data = payload["data"] || {}
    flw_id = data["id"] || data["transaction_id"] || data["tx_ref"]
    tx_ref = data["tx_ref"]
    status = data["status"] || payload.dig("event")

    # find payment by transaction id or tx_ref
    payment = Payment.find_by(transaction_id: flw_id) ||
              Payment.find_by("metadata ->> 'tx_ref' = ?", tx_ref) ||
              Payment.find_by(transaction_id: tx_ref)

    return head :ok unless payment

    order = payment.order

    if status == "successful" || status == "success"
      payment.update!(status: "completed", paid_at: Time.current)
      order.update!(payment_status: "paid", status: "complete")
    elsif status == "failed"
      payment.update!(status: "failed")
      order.update!(payment_status: "failed", status: "cancelled")
    end

    head :ok
  end

  private

  def payment_params
    params.require(:payment).permit(:order_id, :amount, :payment_method, :status, :tx_ref)
  end

  def valid_flutterwave_webhook?
    secret = ENV["FLUTTERWAVE_WEBHOOK_SECRET"].to_s
    return false if secret.blank?

    signature = request.headers["verif-hash"] || request.headers["HTTP_VERIF_HASH"] || request.headers["Verif-Hash"]
    return false if signature.blank?

    # Compare exact equals — Flutterwave uses plain comparison of your secret
    ActiveSupport::SecurityUtils.secure_compare(signature.to_s, secret.to_s)
  end

  def fake_payment_success(order, tx_ref)
    payment = Payment.create!(
      order_id: order.id,
      payment_method: "fake",
      amount: order.total_amount,
      transaction_id: tx_ref,
      status: "completed",
      metadata: { fake: true }
    )

    order.update!(
      payment_status: "paid",
      status: "complete"
    )

    render json: {
      message: "Fake payment success",
      tx_ref: tx_ref,
      payment_id: payment.id,
      redirect_url: "#{ENV['KITUNGA_MARKET_FRONTEND_URL']}/payment/success",
      mode: "fake"
    }, status: :ok
  end

end
