class Spree::Admin::ProductImportsController < Spree::Admin::BaseController
  SAMPLE_CSV_FILE = Rails.root.join("sample_csv", "SpreeMultiVariant.csv")

  def index
    render
  end

  def reset
    truncated_list = ['spree_products_taxons', 'spree_option_values_variants', 'spree_products_promotion_rules']
    result_log = []
    truncated_list.inject(result_log) do |r,t|
      c = "TRUNCATE #{t}"
      ActiveRecord::Base.connection.execute(c)
      r.push("Command executed #{c}")
    end

    model_list = %w{ Image OptionType OptionValue Product Property ProductProperty ProductOptionType
     Variant StockMovement StockItem StockTransfer Taxonomy Taxon ShippingCategory TaxCategory
    }
    model_list.inject(result_log) do |r,m|
      klass = DataShift::SpreeEcom.get_spree_class(m)
      s = "Clearing model #{klass}"
      if(klass)
        begin
          klass.delete_all
        rescue => e
          s += "generated error #{e}"
        end
      else
        s = "#{m} not found or respective Model"
      end
      r.push(s)
    end

    delete_other_than_defaults = %w{ StockLocation }
    delete_other_than_defaults.inject(result_log) do |r,m|
      klass = DataShift::SpreeEcom.get_spree_class(m)
      s = "Clearing Other than Defaults #{klass}"
      if(klass)
        begin
          klass.where.not(default: true).delete_all
        rescue => e
          s += "generated error #{e}"
        end
      else
        s = "#{m} not found or respective Model"
      end
      r.push(s)
    end

    redirect_to admin_product_imports_path, flash: {notice: result_log.join("---,---")}
  end

  def sample_import
    if(File.exists? SAMPLE_CSV_FILE)
      @csv_table = CSV.open(SAMPLE_CSV_FILE, :headers => true).read
      render
    else
      redirect_to admin_product_imports_path, flash: { error: "Sample Missing" }
    end
  end

  def import
    loader = DataShift::SpreeEcom::ProductLoader.new( nil, {:verbose => true})
    opts = {}
    opts[:mandatory] = ['sku', 'name', 'price']
    loader.perform_load(SAMPLE_CSV_FILE, opts)
    redirect_to admin_product_imports_path, flash: { notice: "Check Imported Data" }
  end
end
