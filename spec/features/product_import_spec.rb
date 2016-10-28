require 'spec_helper'

feature "Admin Product Import", js: true do

  stub_authorization!

  scenario 'option value creation' do
    visit spree.admin_product_imports_path

    expect(page).to have_content("Product Import Demo using")
  end
end
