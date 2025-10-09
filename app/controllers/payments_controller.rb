class PaymentsController < ApplicationController
  before_action :set_payment, only: %i[ show update destroy ]

  # GET /payments
  # GET /payments.json
  def index
    @payments = Payment.all
  end

  # GET /payments/1
  # GET /payments/1.json
  def show
  end

  # POST /payments
  # POST /payments.json
  def create
    @payment = Payment.new(payment_params)

    if @payment.save
      render :show, status: :created, location: @payment
    else
      render json: @payment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /payments/1
  # PATCH/PUT /payments/1.json
  def update
    if @payment.update(payment_params)
      render :show, status: :ok, location: @payment
    else
      render json: @payment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy
    @payment.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def payment_params
      params.expect(payment: [ :order_id, :payment_method, :transaction_id, :amount, :status ])
    end
end
