class Payment < ApplicationRecord
  belongs_to :order, optional: false

  # Validations
  validates :payment_method, presence: true
  validates :transaction_id, presence: true, uniqueness: true
  validates :amount, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending completed failed refunded] }

  # Scopes
  scope :completed, -> { where(status: "completed") }
  scope :pending,   -> { where(status: "pending") }

  # Callbacks
  before_create :set_paid_at

  private

  def set_paid_at
    self.paid_at ||= Time.current if status == "completed"
  end
end
