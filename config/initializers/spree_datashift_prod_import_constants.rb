DATASHIFT_CSV_FILES = {
  sample_product_file: Rails.root.join("sample_csv", "SpreeMultiVariant.csv"),
  shopify_products_export_file: Rails.root.join("sample_csv", "shopify_products_export.csv"),
  sample_user_file: Rails.root.join("sample_csv", "customers_export.csv"),
  sample_order_file: Rails.root.join("sample_csv", "orders_export_multiple_paid-fulfilled.csv")
}

PRODUCT_DEPENDENT_MODELS = %w{ Order Image OptionType OptionValue Product Property ProductProperty ProductOptionType Variant StockItem StockTransfer StockLocation Taxonomy Taxon ShippingCategory TaxCategory }

PRODUCT_MANDATORY_FIELDS = ['sku', 'name', 'price', 'shipping_category']
