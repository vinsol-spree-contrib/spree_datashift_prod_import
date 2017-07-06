class Spree::Admin::ProductImportsController < Spree::Admin::BaseController

  before_action :ensure_valid_file, only: [:user_csv_import, :shopify_csv_import]
  before_action :set_loader_options, only: [:sample_csv_import, :user_csv_import]

  def index
    @csv_table = CSV.open(DATASHIFT_CSV_FILES[:sample_product_file], headers: true).read if File.exists? DATASHIFT_CSV_FILES[:sample_product_file]
  end

  def reset
    flash[:success] = Spree::DataResetService.new.reset_products
    redirect_to admin_product_imports_path
  end

  def sample_import
  end

  def download_sample_csv
    send_file DATASHIFT_CSV_FILES[:sample_product_file]
  end

  def sample_csv_import
    begin
      loader = DataShift::SpreeEcom::ProductLoader.new(DATASHIFT_CSV_FILES[:sample_product_file], @options)
      loader.run
      flash[:success] = Spree.t(:successfull_import, scope: :datashift_import, resource: Spree::Product.name.demodulize)
    rescue => e
      flash[:error] = e.message
    end
    redirect_to admin_product_imports_path
  end

  def user_csv_import
    begin
      loader = DataShift::SpreeEcom::ProductLoader.new(params[:csv_file].path, @options)
      loader.run
      flash[:success] = Spree.t(:successfull_import, scope: :datashift_import, resource: Spree::Product.name.demodulize)
    rescue => e
      flash[:error] = e.message
    end
    redirect_to admin_product_imports_path
  end

  def download_sample_shopify_export_csv
    send_file DATASHIFT_CSV_FILES[:shopify_products_export_file]
  end

  def shopify_csv_import
    begin
      transformer = DataShift::SpreeEcom::ShopifyProductTransform.new(params[:csv_file].path)
      send_data transformer.to_csv,
        type: 'text/csv; charset=iso-8859-1; header=present',
        filename: 'shopify_to_spree_mapper.csv'
    rescue => e
      flash[:error] = e.message
      redirect_to sample_import_admin_product_imports_path
    end
  end

  private
    def ensure_valid_file
      unless params[:csv_file].try(:respond_to?, :path)
        flash[:error] = Spree.t(:file_invalid_error, scope: :datashift_import)
        redirect_to admin_product_imports_path
      end
    end

    def set_loader_options
      @options ||= {}
      @options[:mandatory] = PRODUCT_MANDATORY_FIELDS
    end
end
