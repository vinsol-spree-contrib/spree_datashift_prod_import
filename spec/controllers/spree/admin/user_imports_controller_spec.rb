require 'spec_helper'

describe Spree::Admin::UserImportsController, type: :controller do

  stub_authorization!

  describe 'index' do

    def send_request
      spree_get :index
    end

    let(:non_admins) { double(ActiveRecord::Relation) }
    let(:non_admin_user_count) { 3 }
    let(:csv_object) { CSV.open(DATASHIFT_CSV_FILES[:sample_user_file]) }
    let(:csv_table_object) { csv_object.read }

    before do
      allow(Spree.user_class).to receive(:non_admins).and_return(non_admins)
      allow(non_admins).to receive(:count).and_return(non_admin_user_count)
      allow(CSV).to receive(:open).and_return(csv_object)
      allow(csv_object).to receive(:read).and_return(csv_table_object)
    end

    describe 'expects to receive' do
      after { send_request }
      it { expect(Spree.user_class).to receive(:non_admins).and_return(non_admins) }
      it { expect(non_admins).to receive(:count).and_return(non_admin_user_count) }
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
    let(:reset_users) { double ActiveRecord::Relation }

    def send_request
      spree_delete :reset
    end

    before do
      allow(Spree::DataResetService).to receive(:new).and_return(data_reset_service_object)
      allow(data_reset_service_object).to receive(:reset_users_with_orders).and_return(Spree.t(:users, scope: [:datashift_import, :reset_message]))
    end

    describe 'expects to receive' do
      after { send_request }
      it { expect(Spree::DataResetService).to receive(:new).and_return(data_reset_service_object) }
      it { expect(data_reset_service_object).to receive(:reset_users_with_orders).and_return(Spree.t(:users, scope: [:datashift_import, :reset_message])) }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(302) }
      it { expect(response).to redirect_to admin_user_imports_path }
      it { expect(flash[:success]).to eq Spree.t(:users, scope: [:datashift_import, :reset_message]) }
    end

  end

  describe 'download_sample_csv' do

    def send_request
      spree_get :download_sample_csv
    end

    before do
      allow(controller).to receive(:send_file) { controller.render body: nil }
    end

    describe 'response' do
      before { send_request }
      it { expect(response).to have_http_status(:ok) }
    end

  end

  describe 'sample_csv_import' do

    let(:loader_options) { { verbose: true, address_type: 'bill_address' } }
    let(:user_loader) { DataShift::SpreeEcom::ShopifyCustomerLoader.new(DATASHIFT_CSV_FILES[:sample_user_file], loader_options) }
    let(:loader_params) { { address_type: 'bill_address'}.with_indifferent_access }

    def send_request(params = {})
      spree_post :sample_csv_import, params
    end

    context 'when import is successfull' do
      before do
        allow(DataShift::SpreeEcom::ShopifyCustomerLoader).to receive(:new).with(DATASHIFT_CSV_FILES[:sample_user_file], loader_options).and_return(user_loader)
        allow(user_loader).to receive(:run)
      end

      describe 'expects to receive' do
        after { send_request(loader_params) }
        it { expect(DataShift::SpreeEcom::ShopifyCustomerLoader).to receive(:new).with(DATASHIFT_CSV_FILES[:sample_user_file], loader_options).and_return(user_loader) }
        it { expect(user_loader).to receive(:run) }
      end

      describe 'response' do
        before { send_request(loader_params) }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_user_imports_path }
        it { expect(flash[:success]).to eq Spree.t(:successfull_import, scope: :datashift_import, resource: Spree.user_class.name.demodulize) }
      end
    end

    context 'when exception is raised while importing' do
      before do
        allow(DataShift::SpreeEcom::ShopifyCustomerLoader).to receive(:new).with(DATASHIFT_CSV_FILES[:sample_user_file], loader_options).and_return(user_loader)
        allow(user_loader).to receive(:run).and_raise(StandardError, 'something went wrong')
      end

      describe 'expects to receive' do
        after { send_request(loader_params) }
        it { expect(DataShift::SpreeEcom::ShopifyCustomerLoader).to receive(:new).with(DATASHIFT_CSV_FILES[:sample_user_file], loader_options).and_return(user_loader) }
        it { expect(user_loader).to receive(:run).and_raise(StandardError, 'something went wrong') }
      end

      describe 'response' do
        before { send_request(loader_params) }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_user_imports_path }
        it { expect(flash[:error]).to eq 'something went wrong' }
      end
    end

  end

  describe 'user_csv_import' do
    let(:csv_file) { Rack::Test::UploadedFile.new(DATASHIFT_CSV_FILES[:sample_user_file].to_s, 'text/csv') }
    let(:import_params) { { csv_file: csv_file, address_type: 'bill_address' }.with_indifferent_access }
    let(:loader_options) { { verbose: true, address_type: 'bill_address' } }
    let(:user_loader) { double('user_loader') }

    def send_request(params = {})
      spree_post :user_csv_import, params
    end

    context 'when csv file not present in params' do
      describe 'response' do
        before { send_request }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_user_imports_path }
        it { expect(flash[:error]).to eq Spree.t(:file_invalid_error, scope: :datashift_import) }
      end
    end

    context 'when csv file present in params and import is successfull' do
      before do
        allow(DataShift::SpreeEcom::ShopifyCustomerLoader).to receive(:new).and_return(user_loader)
        allow(user_loader).to receive(:run)
      end

      describe 'expects to receive' do
        after { send_request(import_params) }
        it { expect(DataShift::SpreeEcom::ShopifyCustomerLoader).to receive(:new).and_return(user_loader) }
        it { expect(user_loader).to receive(:run) }
      end

      describe 'response' do
        before { send_request(import_params) }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_user_imports_path }
        it { expect(flash[:success]).to eq Spree.t(:successfull_import, scope: :datashift_import, resource: Spree.user_class.name.demodulize) }
      end
    end

    context 'when csv file present in params and import is unsuccessfull' do
      before do
        allow(DataShift::SpreeEcom::ShopifyCustomerLoader).to receive(:new).and_return(user_loader)
        allow(user_loader).to receive(:run).and_raise(StandardError, 'something went wrong')
      end

      describe 'expects to receive' do
        after { send_request(import_params) }
        it { expect(DataShift::SpreeEcom::ShopifyCustomerLoader).to receive(:new).and_return(user_loader) }
        it { expect(user_loader).to receive(:run).and_raise(StandardError, 'something went wrong') }
      end

      describe 'response' do
        before { send_request(import_params) }
        it { expect(response).to have_http_status(302) }
        it { expect(response).to redirect_to admin_user_imports_path }
        it { expect(flash[:error]).to eq 'something went wrong' }
      end
    end

  end
end
