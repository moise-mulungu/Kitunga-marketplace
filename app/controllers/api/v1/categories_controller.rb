module Api
  module V1
    class CategoriesController < BaseController
      # before_action :set_category, only: [:show, :update, :destroy]
      skip_before_action :authorize_request, only: [ :index ]

      def index
        categories = Category.select(:id, :name, :slug, :description, :category_type)
        render json: categories
      end

      def show
        render json: @category
      end

      def create
        category = Category.new(category_params)
        if category.save
          render json: category, status: :created
        else
          render json: { errors: category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @category.update(category_params)
          render json: @category
        else
          render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @category.destroy
        head :no_content
      end

      private

      # def set_category
      #   @category = Category.find_by!(slug: params[:id])
      # rescue ActiveRecord::RecordNotFound
      #   render json: { error: "Category not found" }, status: :not_found
      # end

      def category_params
        params.require(:category).permit(:name, :slug, :category_type)
      end
    end
  end
end
