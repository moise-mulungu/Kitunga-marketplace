class Product < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true

  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many_attached :images # if using ActiveStorage

  validates :title, :price, :quantity, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :slug, presence: true, uniqueness: true
  validate :slug_cannot_start_with_reserved_word

  scope :available, -> { where(available: true) }

  before_validation :generate_unique_slug

  # ✅ Generate unique slug combining category name + title
  def generate_unique_slug
    return unless title.present?

    category_part = category&.name.to_s.parameterize
    base_slug = [category_part, title].compact.join('-').parameterize

    slug_candidate = base_slug
    counter = 2

    # 🔁 Always ensure a slug exists, even if product is already persisted
    while Product.where.not(id: id).exists?(slug: slug_candidate)
      slug_candidate = "#{base_slug}-#{counter}"
      counter += 1
    end

    self.slug = slug_candidate if slug.blank? || slug != slug_candidate
  end


  def slug_cannot_start_with_reserved_word
    if slug&.start_with?('category-')
      errors.add(:slug, "cannot start with 'category-' because it's reserved for routes")
    end
  end


  def to_param
    slug.presence || id.to_s
  end

  # 🔍 Search & filtering helper
  def self.search_and_filter(params)
    products = Product.available.includes(:category, :user)

    if params[:category].present?
      products = products.joins(:category).where(categories: { slug: params[:category] })
    end

    if params[:search].present?
      query = "%#{params[:search].strip.downcase}%"
      products = products.where(
        "LOWER(title) LIKE ? OR LOWER(description) LIKE ? OR tags::text ILIKE ?",
        query, query, query
      )
    end

    if params[:sort].present?
      order = case params[:sort]
              when 'price_asc' then 'price ASC'
              when 'price_desc' then 'price DESC'
              when 'newest' then 'created_at DESC'
              else 'created_at DESC'
              end
      products = products.order(order)
    else
      products = products.order(created_at: :desc)
    end

    products
  end

  include Rails.application.routes.url_helpers

  def primary_image_url
    return nil unless images.attached?

    rails_blob_url(images.first, only_path: false)
  end

end
