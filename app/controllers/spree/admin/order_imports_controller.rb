class Spree::Admin::OrderImportsController < Spree::Admin::BaseController
  SAMPLE_CSV_FILE = Rails.root.join("sample_csv", "orders_export_multiple_paid-fulfilled.csv")

  def index
    render
  end

  def reset
    result_log = []
    Spree::Order.destroy_all.each do |o|
      result_log << o.number
    end

    redirect_to admin_order_imports_path, flash: {notice: result_log.join("---,---")}
  end

  def sample_import
    if(File.exists? SAMPLE_CSV_FILE)
      @csv_table = CSV.open(SAMPLE_CSV_FILE, :headers => true).read
      render
    else
      redirect_to admin_order_imports_path, flash: { error: "Sample Missing" }
    end
  end

  def download_sample_csv
    send_file SAMPLE_CSV_FILE
  end

  def sample_csv_import
    opts = {}
    loader = DataShift::SpreeEcom::ShopifyOrderLoader.new( Spree::Order, {:verbose => true})
    loader.perform_load(SAMPLE_CSV_FILE, opts)
    redirect_to admin_order_imports_path, flash: { notice: "Check Sample Imported Data" }
  end

  def user_csv_import
    opts = {}
    loader = DataShift::SpreeEcom::ShopifyOrderLoader.new( Spree::Order, {:verbose => true})
    message = "Check Imported Data"
    if params[:csv_file]
      if params[:csv_file].respond_to?(:path)
        loader.perform_load(params[:csv_file].path, opts)
      else
        message = "Please upload a valid file"
      end
    else
      message = "No File Given"
    end
    redirect_to admin_order_imports_path, flash: { notice: message }
  end
end
