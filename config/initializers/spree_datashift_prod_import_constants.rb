DATASHIFT_CSV_FILES = {
  sample_product_file: SpreeDatashiftProdImport::Engine.root.join('lib', 'sample_csv_files', 'SpreeMultiVariant.csv'),
  shopify_products_export_file: SpreeDatashiftProdImport::Engine.root.join('lib', 'sample_csv_files', 'shopify_products_export.csv'),
  sample_user_file: SpreeDatashiftProdImport::Engine.root.join('lib', 'sample_csv_files', 'customers_export.csv'),
  sample_order_file: SpreeDatashiftProdImport::Engine.root.join('lib', 'sample_csv_files', 'orders_export_multiple_paid-fulfilled.csv')
}

PRODUCT_DEPENDENT_MODELS = %w{ Order Image OptionType OptionValue Product Property ProductProperty ProductOptionType Variant StockItem StockTransfer StockLocation Taxonomy Taxon ShippingCategory TaxCategory }

PRODUCT_MANDATORY_FIELDS = ['sku', 'name', 'price', 'shipping_category']
