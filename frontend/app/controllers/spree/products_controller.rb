module Spree
  class ProductsController < Spree::StoreController
    before_filter :load_product, :only => :show
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    helper 'spree/taxons'

    respond_to :html

    def index
      @searcher = build_searcher(params)
      @products = @searcher.retrieve_products
      @taxonomies = Spree::Taxonomy.includes(root: :children)
    end

    def show
      return unless @product

      @variants = @product.variants_including_master.active(current_currency).includes([:option_values, :images])
      @product_properties = @product.product_properties.includes(:property)
      @taxon = Spree::Taxon.find(params[:taxon_id]) if params[:taxon_id]
      respond_with(@product) if !try_spree_current_user && stale?(@product)
    end

    private
      def accurate_title
        @product ? @product.name : super
      end

      def load_product
        if try_spree_current_user.try(:has_spree_role?, "admin")
          @product = Product.find_by_permalink!(params[:id])
        else
          @product = Product.active(current_currency).find_by_permalink!(params[:id])
        end
      end
  end
end
