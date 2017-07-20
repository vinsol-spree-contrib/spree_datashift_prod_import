Spree::AppConfiguration.class_eval do
  preference :allow_datashift_reset, :boolean, default: false
end
