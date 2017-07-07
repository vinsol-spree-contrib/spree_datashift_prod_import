require 'spec_helper'

describe Spree::Admin::ProductImportsController, type: :controller do

  stub_authorization!

  describe 'index' do

    def send_request
      spree_get :index
    end

    let(:csv_object) { CSV.open(DATASHIFT_CSV_FILES[:sample_product_file]) }
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
    let(:reset_products_message) { 'products remove successfully' }

    def send_request
      spree_delete :reset
    end

    before do
      allow(Spree::DataResetService).to receive(:new).and_return(data_reset_service_object)
      allow(data_reset_service_object).to receive(:reset_products).and_return(reset_products_message)
    end

    describe 'expects to receive' do
      after { send_request }
      it { expect(Spree::DataResetService).to receive(:new).and_return(data_reset_service_object) }
      it { expect(data_reset_service_object).to receive(:reset_products).and_return(reset_products_message) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(302) }
      it { expect(response).to redirect_to admin_product_imports_path }
      it { expect(flash[:success]).to eq reset_products_message }
    end

  end

  describe 'download_sample_csv' do

    def send_request
      spree_get :download_sample_csv
    end

    before do
      allow(controller).to receive(:send_file).with(DATASHIFT_CSV_FILES[:sample_product_file]) { controller.render body: nil }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(200) }
    end

  end

  describe 'sample_csv_import' do

    let(:loader_options) { { mandatory: PRODUCT_MANDATORY_FIELDS } }
    let(:product_loader) { double('Porduct Loader') }

    def send_request(params = {})
      spree_post :sample_csv_import, params
    end

    context 'when import is successfull' do
      before do
        allow(DataShift::SpreeEcom::ProductLoader).to receive(:new).with(DATASHIFT_CSV_FILES[:sample_product_file], loader_options).and_return(product_loader)
        allow(product_loader).to receive(:run)
      end

      describe 'expects to receive' do
        after { send_request }
        it { expect(DataShift::SpreeEcom::ProductLoader).to receive(:new).with(DATASHIFT_CSV_FILES[:sample_product_file], loader_options).and_return(product_loader) }
        it { expect(product_loader).to receive(:run) }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_product_imports_path }
        it { expect(flash[:success]).to eq Spree.t(:successfull_import, scope: :datashift_import, resource: Spree::Product.name.demodulize) }
      end
    end

    context 'when exception is raised while importing' do
      before do
        allow(DataShift::SpreeEcom::ProductLoader).to receive(:new).with(DATASHIFT_CSV_FILES[:sample_product_file], loader_options).and_return(product_loader)
        allow(product_loader).to receive(:run).and_raise(StandardError, 'something went wrong')
      end

      describe 'expects to receive' do
        after { send_request }
        it { expect(DataShift::SpreeEcom::ProductLoader).to receive(:new).with(DATASHIFT_CSV_FILES[:sample_product_file], loader_options).and_return(product_loader) }
        it { expect(product_loader).to receive(:run).and_raise(StandardError, 'something went wrong') }
      end

      describe 'response' do
        before { send_request }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_product_imports_path }
        it { expect(flash[:error]).to eq 'something went wrong' }
      end
    end

  end

  describe 'user_csv_import' do

    let(:import_params) { { csv_file: Rack::Test::UploadedFile.new(DATASHIFT_CSV_FILES[:sample_product_file].to_s) }.with_indifferent_access }
    let(:loader_options) { { mandatory: PRODUCT_MANDATORY_FIELDS } }
    let(:product_loader) { double('Porduct Loader') }

    def send_request(params = {})
      spree_post :user_csv_import, params
    end

    context 'when csv file not present in params' do
      describe 'response' do
        before { send_request }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_product_imports_path }
        it { expect(flash[:error]).to eq Spree.t(:file_invalid_error, scope: :datashift_import) }
      end
    end

    context 'when csv file present in params and import is successfull' do
      before do
        allow(DataShift::SpreeEcom::ProductLoader).to receive(:new).and_return(product_loader)
        allow(product_loader).to receive(:run)
      end

      describe 'expects to receive' do
        after { send_request(import_params) }
        it { expect(DataShift::SpreeEcom::ProductLoader).to receive(:new).and_return(product_loader) }
        it { expect(product_loader).to receive(:run) }
      end

      describe 'response' do
        before { send_request(import_params) }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_product_imports_path }
        it { expect(flash[:success]).to eq Spree.t(:successfull_import, scope: :datashift_import, resource: Spree::Product.name.demodulize) }
      end
    end

    context 'when csv file present in params and import is unsuccessfull' do
      before do
        allow(DataShift::SpreeEcom::ProductLoader).to receive(:new).and_return(product_loader)
        allow(product_loader).to receive(:run).and_raise(StandardError, 'something went wrong')
      end

      describe 'expects to receive' do
        after { send_request(import_params) }
        it { expect(DataShift::SpreeEcom::ProductLoader).to receive(:new).and_return(product_loader) }
        it { expect(product_loader).to receive(:run).and_raise(StandardError, 'something went wrong') }
      end

      describe 'response' do
        before { send_request(import_params) }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_product_imports_path }
        it { expect(flash[:error]).to eq 'something went wrong' }
      end
    end

  end

  describe 'download_sample_shopify_export_csv' do

    def send_request
      spree_get :download_sample_shopify_export_csv
    end

    before do
      allow(controller).to receive(:send_file).with(DATASHIFT_CSV_FILES[:shopify_products_export_file]) { controller.render body: nil }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(200) }
    end

  end

  describe 'shopify_csv_import' do

    let(:tranform_params) { { csv_file: Rack::Test::UploadedFile.new(DATASHIFT_CSV_FILES[:shopify_products_export_file].to_s) }.with_indifferent_access }
    let(:loader_options) { { mandatory: PRODUCT_MANDATORY_FIELDS } }
    let(:transformer) { DataShift::SpreeEcom::ShopifyProductTransform.new(tranform_params[:csv_file].path) }

    def send_request(params = {})
      spree_post :shopify_csv_import, params
    end

    context 'when csv file not present in params' do
      describe 'response' do
        before { send_request }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_product_imports_path }
        it { expect(flash[:error]).to eq Spree.t(:file_invalid_error, scope: :datashift_import) }
      end
    end

    context 'when csv file present in params and import is successfull' do
      before do
        allow(DataShift::SpreeEcom::ShopifyProductTransform).to receive(:new).and_return(transformer)
        allow(transformer).to receive(:to_csv)
        allow(controller).to receive(:send_file)
        allow(controller).to receive(:render)
      end

      describe 'expects to receive' do
        after { send_request(tranform_params) }
        it { expect(DataShift::SpreeEcom::ShopifyProductTransform).to receive(:new).and_return(transformer) }
        it { expect(transformer).to receive(:to_csv) }
      end

      describe 'response' do
        before { send_request(tranform_params) }
        it { expect(response).to have_http_status(204) }
      end
    end

    context 'when csv file present in params and import is unsuccessfull' do
      before do
        allow(DataShift::SpreeEcom::ShopifyProductTransform).to receive(:new).and_return(transformer)
        allow(transformer).to receive(:to_csv).and_raise(StandardError, 'something went wrong')
      end

      describe 'expects to receive' do
        after { send_request(tranform_params) }
        it { expect(DataShift::SpreeEcom::ShopifyProductTransform).to receive(:new).and_return(transformer) }
        it { expect(transformer).to receive(:to_csv).and_raise(StandardError, 'something went wrong') }
      end

      describe 'response' do
        before { send_request(tranform_params) }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to sample_import_admin_product_imports_path }
        it { expect(flash[:error]).to eq 'something went wrong' }
      end
    end

  end

end
