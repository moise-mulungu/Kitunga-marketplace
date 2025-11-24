class AdminActionLog < ApplicationRecord
  belongs_to :admin, class_name: "User", foreign_key: "admin_id", optional: true

  validates :action, presence: true

  def details_hash
    JSON.parse(details || "{}") rescue {}
  end
end
