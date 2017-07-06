module SpreeDatashiftProdImport
  class Engine < Rails::Engine
    require 'spree/core'
    require 'csv'
    require 'datashift'
    require 'datashift_spree'
    require 'mechanize'

    isolate_namespace Spree
    engine_name 'spree_datashift_prod_import'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
