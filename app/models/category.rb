class Category < ApplicationRecord
  # Associations
  has_many :products, dependent: :nullify

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true

  # Scopes
  scope :ordered, -> { order(:name) }
  scope :product_categories, -> { where(category_type: "product") }
  scope :service_categories, -> { where(category_type: "service") }

  # Callbacks
  before_validation :generate_slug, on: [ :create, :update ]

  # Generate a URL-friendly slug from the name
  def generate_slug
    return if name.blank?
    candidate = name.to_s.parameterize
    # Ensure uniqueness by appending a counter when necessary
    base = candidate
    counter = 1
    while Category.exists?(slug: candidate) && (self.slug.nil? || Category.find_by(slug: candidate).id != id)
      counter += 1
      candidate = "#{base}-#{counter}"
    end
    self.slug = candidate
  end

  # Use slug in URLs
  def to_param
    slug
  end
end
