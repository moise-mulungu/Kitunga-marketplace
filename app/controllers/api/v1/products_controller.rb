class Api::V1::ProductsController <  Api::V1::BaseController
  include Devise::Controllers::Helpers  # ensures authenticate_user! works

  before_action :authenticate_user!, except: [ :index, :show ]   # only protect create/update/destroy
  before_action :authorize_seller!, only: [ :create, :update, :destroy ]

  def index
    products = Product.all

    products = products.where(user_id: params[:seller_id]) if params[:seller_id].present?
    products = products.where(category_id: params[:category_id]) if params[:category_id].present?
    products = products.where("title ILIKE :q OR description ILIKE :q", q: "%#{params[:search]}%") if params[:search].present?

    if params[:category].present?
      category = Category.find_by(slug: params[:category])
      products = products.where(category_id: category.id) if category
    end

    render json: products.map { |product| product_json(product) }
  end

  def show
    product = Product.find_by!(slug: params[:id]) || Product.find(params[:id])
    render json: product_json(product)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found" }, status: :not_found
  end

  def create
    product = current_user.products.build(product_params)

    # Map seller's string category → Category model
    if current_user.seller?
      category = Category.find_by(slug: current_user.category)
      product.category = category
    end

    if product.save
      product.images.attach(params[:product][:images]) if params[:product][:images].present?
      render json: product_json(product), status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    product = Product.find(params[:id])
    unless current_user.admin? || product.user_id == current_user.id
      return render json: { error: "Forbidden" }, status: :forbidden
    end

    category = Category.find_by(slug: current_user.category)
    product.category = category if current_user.seller?


    if product.update(product_params)
      render json: product_json(product)
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end


  def destroy
    product = Product.find(params[:id])
    # Only owner or admin can delete
    unless current_user.admin? || product.user_id == current_user.id
      return render json: { error: "Forbidden" }, status: :forbidden
    end

    product.destroy
    head :no_content
  end

  private

  def product_params
    params.require(:product).permit(:title, :description, :price, :quantity, :category_id, images: [])
  end

  def authorize_seller!
    render json: { error: "Not authorized" }, status: :forbidden unless current_user.seller? || current_user.admin?
  end

  def product_json(product)
    product.as_json(
      only: [ :id, :title, :description, :price, :quantity, :image_url, :slug, :category_id ],
      include: {
        category: { only: [ :id, :name ] },
        user: { only: [ :id, :name ], methods: [ :profile_image_url ] }  # optional
      }
    ).merge(
      images: product.images.attached? ? product.images.map { |img| url_for(img) } : []
    )
  end
end
