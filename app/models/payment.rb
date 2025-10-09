class Payment < ApplicationRecord
  belongs_to :order

  enum :status, { pending: "pending", completed: "completed", failed: "failed" }

  validates :amount, numericality: { greater_than: 0 }, presence: true
end
