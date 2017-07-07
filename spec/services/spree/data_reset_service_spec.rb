require 'spec_helper'

describe Spree::DataResetService do

  let(:reset_object) { Spree::DataResetService.new }

  describe '#reset_orders' do

    let!(:order_1) { create(:order) }
    let!(:order_2) { create(:order) }

    it '#check order count' do
      reset_object.reset_orders
      expect(Spree::Order.count).to eq(0)
    end

    it { expect(reset_object.reset_orders).to eq([order_1, order_2].map(&:number).join(', ')) }

  end

  describe 'reset_users' do

    let!(:user_1) { create(:user) }
    let!(:admin) { create(:admin_user) }

    it { expect(reset_object.reset_users).to include(user_1) }
    it { expect(reset_object.reset_users).to_not include(admin) }

  end

  describe 'reset users with orders' do
    let!(:user_1) { create(:user) }
    let!(:admin) { create(:admin_user) }
    let!(:order_1) { create(:order, user_id: user_1.id) }
    let!(:order_2) { create(:order, user_id: admin.id) }

    before { reset_object.reset_users_with_orders }

    it { expect(Spree::User.all).to_not include(user_1) }
    it { expect(Spree::User.all).to include(admin) }
    it { expect(Spree::Order.all).to_not include(order_1) }
    it { expect(Spree::Order.all).to include(order_2) }

  end

  describe 'reset_products' do
    let!(:product) { create(:product) }
    let!(:variant) { create(:variant, product_id: product.id) }

    before { reset_object.reset_products }

    it 'check order count'do
      expect(Spree::Order.count).to eq(0)
    end

    it 'check product count'do
      expect(Spree::Product.count).to eq(0)
    end

    it 'check variant count'do
      expect(Spree::Variant.count).to eq(0)
    end

    it 'check property count'do
      expect(Spree::Property.count).to eq(0)
    end

    it 'check option type count'do
      expect(Spree::OptionType.count).to eq(0)
    end

    it 'check option value count'do
      expect(Spree::OptionValue.count).to eq(0)
    end

    it 'check product property count'do
      expect(Spree::ProductProperty.count).to eq(0)
    end

    it 'check stock_item count'do
      expect(Spree::StockItem.count).to eq(0)
    end

    it 'check StockTransfer count'do
      expect(Spree::StockTransfer.count).to eq(0)
    end

    it 'check StockLocation count'do
      expect(Spree::StockLocation.count).to eq(0)
    end

    it 'check Taxonomy count'do
      expect(Spree::Taxonomy.count).to eq(0)
    end

    it 'check Taxon count'do
      expect(Spree::Taxon.count).to eq(0)
    end

    it 'check ShippingCategory count'do
      expect(Spree::ShippingCategory.count).to eq(0)
    end

    it 'check TaxCategory count'do
      expect(Spree::TaxCategory.count).to eq(0)
    end

  end

end
