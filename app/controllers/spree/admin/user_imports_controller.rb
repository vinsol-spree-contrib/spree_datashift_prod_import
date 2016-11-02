class Spree::Admin::UserImportsController < Spree::Admin::BaseController
  SAMPLE_CSV_FILE = Rails.root.join("sample_csv", "customers_export.csv")

  def index
    render
  end

  def reset
    result_log = []

    admin_role = Spree::Role.where(name: 'admin').first
    admin_user_ids = admin_role.users.pluck(:id)
    Spree::User.where('id NOT IN (?)', admin_user_ids).destroy_all.each do |u|
      result_log << u.login
    end

    redirect_to admin_user_imports_path, flash: {notice: result_log.join("---,---")}
  end

  def sample_import
    admin_role = Spree::Role.where(name: 'admin').first
    admin_user_ids = admin_role.users.pluck(:id)
    @admin_user_count = Spree::User.where('id NOT IN (?)', admin_user_ids).count

    if(File.exists? SAMPLE_CSV_FILE)
      @csv_table = CSV.open(SAMPLE_CSV_FILE, :headers => true).read
      render
    else
      redirect_to admin_user_imports_path, flash: { error: "Sample Missing" }
    end
  end

  def download_sample_csv
    send_file SAMPLE_CSV_FILE
  end

  def sample_csv_import
    opts = {}
    loader = DataShift::SpreeEcom::ShopifyCustomerLoader.new( nil, {:verbose => true})
    loader.perform_load(SAMPLE_CSV_FILE, opts)
    redirect_to admin_user_imports_path, flash: { notice: "Check Sample Imported Data" }
  end

  def user_csv_import
    opts = {}
    loader = DataShift::SpreeEcom::ShopifyCustomerLoader.new( nil, {:verbose => true, :address_type => params[:address_type]})
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
    redirect_to admin_user_imports_path, flash: { notice: message }
  end
end
