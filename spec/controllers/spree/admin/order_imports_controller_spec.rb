require 'spec_helper'

describe Spree::Admin::OrderImportsController, type: :controller do

  stub_authorization!

  describe 'index' do

    def send_request
      spree_get :index
    end

    let(:csv_object) { CSV.open(DATASHIFT_CSV_FILES[:sample_order_file]) }
    let(:csv_table_object) { csv_object.read }

    before do
      allow(CSV).to receive(:open).and_return(csv_object)
      allow(csv_object).to receive(:read).and_return(csv_table_object)
    end

    describe 'expects to receive' do
      after { send_request }
      it { expect(CSV).to receive(:open).and_return(csv_object) }
      it { expect(csv_object).to receive(:read).and_return(csv_table_object) }
    end

    describe 'assigns' do
      before { send_request }
      it { expect(assigns(:csv_table)).to eq(csv_table_object) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(:ok) }
      it { expect(response).to render_template :index }
    end

  end

  describe 'reset' do

    let(:data_reset_service_object) { Spree::DataResetService.new }
    let(:reset_orders) { 'R11111111, R22222222' }

    def send_request
      spree_delete :reset
    end

    before do
      allow(Spree::DataResetService).to receive(:new).and_return(data_reset_service_object)
      allow(data_reset_service_object).to receive(:reset_orders).and_return(reset_orders)
    end

    describe 'expects to receive' do
      after { send_request }
      it { expect(Spree::DataResetService).to receive(:new).and_return(data_reset_service_object) }
      it { expect(data_reset_service_object).to receive(:reset_orders).and_return(reset_orders) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(302) }
      it { expect(response).to redirect_to admin_order_imports_path }
      it { expect(flash[:success]).to eq Spree.t(:orders, scope: [:datashift_import, :reset_message], order_numbers: reset_orders) }
    end

  end

  describe 'download_sample_csv' do

    def send_request
      spree_get :download_sample_csv
    end

    before do
      allow(controller).to receive(:send_file) { controller.render body: :nil }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(:ok) }
    end

  end

  describe 'sample_csv_import' do

    let(:order_loader) { double('order loader') }

    def send_request
      spree_post :sample_csv_import
    end

    context 'when import is successfull' do
      before do
        allow(DataShift::SpreeEcom::ShopifyOrderLoader).to receive(:new).with(DATASHIFT_CSV_FILES[:sample_order_file], { verbose: true }).and_return(order_loader)
        allow(order_loader).to receive(:run)
      end

      describe 'expects to receive' do
        after { send_request }
        it { expect(DataShift::SpreeEcom::ShopifyOrderLoader).to receive(:new).with(DATASHIFT_CSV_FILES[:sample_order_file], { verbose: true }).and_return(order_loader) }
        it { expect(order_loader).to receive(:run) }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_order_imports_path }
        it { expect(flash[:success]).to eq Spree.t(:successfull_import, scope: :datashift_import, resource: Spree::Order.name.demodulize) }
      end
    end

    context 'when exception is raised while importing' do
      before do
        allow(DataShift::SpreeEcom::ShopifyOrderLoader).to receive(:new).with(DATASHIFT_CSV_FILES[:sample_order_file], { verbose: true }).and_return(order_loader)
        allow(order_loader).to receive(:run).and_raise(StandardError, 'something went wrong')
      end

      describe 'expects to receive' do
        after { send_request }
        it { expect(DataShift::SpreeEcom::ShopifyOrderLoader).to receive(:new).with(DATASHIFT_CSV_FILES[:sample_order_file], { verbose: true }).and_return(order_loader) }
        it { expect(order_loader).to receive(:run).and_raise(StandardError, 'something went wrong') }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_order_imports_path }
        it { expect(flash[:error]).to eq 'something went wrong' }
      end
    end

  end

  describe 'user_csv_import' do

    let(:import_params) { { csv_file: Rack::Test::UploadedFile.new(DATASHIFT_CSV_FILES[:sample_order_file].to_s) }.with_indifferent_access }
    let(:order_loader) { DataShift::SpreeEcom::ShopifyOrderLoader.new(Spree::Order) }

    def send_request(params = {})
      spree_post :user_csv_import, params
    end

    context 'when csv file not present in params' do
      describe 'response' do
        before { send_request }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_order_imports_path }
        it { expect(flash[:error]).to eq Spree.t(:file_invalid_error, scope: :datashift_import) }
      end
    end

    context 'when csv file present in params and import is successfull' do
      before do
        allow(DataShift::SpreeEcom::ShopifyOrderLoader).to receive(:new).and_return(order_loader)
        allow(order_loader).to receive(:run)
      end

      describe 'expects to receive' do
        after { send_request(import_params) }
        it { expect(DataShift::SpreeEcom::ShopifyOrderLoader).to receive(:new).and_return(order_loader) }
        it { expect(order_loader).to receive(:run) }
      end

      describe 'response' do
        before { send_request(import_params) }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_order_imports_path }
        it { expect(flash[:success]).to eq Spree.t(:successfull_import, scope: :datashift_import, resource: Spree::Order.name.demodulize) }
      end
    end

    context 'when csv file present in params and import is unsuccessfull' do
      before do
        allow(DataShift::SpreeEcom::ShopifyOrderLoader).to receive(:new).and_return(order_loader)
        allow(order_loader).to receive(:run).and_raise(StandardError, 'something went wrong')
      end

      describe 'expects to receive' do
        after { send_request(import_params) }
        it { expect(DataShift::SpreeEcom::ShopifyOrderLoader).to receive(:new).and_return(order_loader) }
        it { expect(order_loader).to receive(:run).and_raise(StandardError, 'something went wrong') }
      end

      describe 'response' do
        before { send_request(import_params) }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_order_imports_path }
        it { expect(flash[:error]).to eq 'something went wrong' }
      end
    end

  end
end
