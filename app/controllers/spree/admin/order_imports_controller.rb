class Spree::Admin::OrderImportsController < Spree::Admin::BaseController

  before_action :ensure_valid_file, only: :user_csv_import

  def index
    @csv_table = CSV.open(DATASHIFT_CSV_FILES[:sample_order_file], headers: true).read
  end

  def reset
    flash[:success] = Spree.t(:orders, scope: [:datashift_import, :reset_message], order_numbers: Spree::DataResetService.new.reset_orders)
    redirect_to admin_order_imports_path
  end

  def sample_import
  end

  def download_sample_csv
    send_file DATASHIFT_CSV_FILES[:sample_order_file]
  end

  def sample_csv_import
    begin
      loader = DataShift::SpreeEcom::ShopifyOrderLoader.new(DATASHIFT_CSV_FILES[:sample_order_file], { verbose: true })
      loader.run
      flash[:success] = Spree.t(:successfull_import, scope: :datashift_import, resource: Spree::Order.name.demodulize)
    rescue => e
      flash[:error] = e.message
    end
    redirect_to admin_order_imports_path
  end

  def user_csv_import
    begin
      loader = DataShift::SpreeEcom::ShopifyOrderLoader.new(params[:csv_file].path, { verbose: true })
      loader.run
      flash[:success] = Spree.t(:successfull_import, scope: :datashift_import, resource: Spree::Order.name.demodulize)
    rescue => e
      flash[:error] = e.message
    end
    redirect_to admin_order_imports_path
  end

  private

    def ensure_valid_file
      unless params[:csv_file].try(:respond_to?, :path)
        flash[:error] = Spree.t(:file_invalid_error, scope: :datashift_import)
        redirect_to admin_order_imports_path
      end
    end

end
