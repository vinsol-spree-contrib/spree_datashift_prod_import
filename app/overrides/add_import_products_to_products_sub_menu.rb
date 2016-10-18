Deface::Override.new(
  virtual_path: 'spree/admin/shared/sub_menu/_product',
  name: 'import_products_tab',
  insert_bottom: "#sidebar-product",
  text: %Q{ <%= tab :product_imports %> }
)
