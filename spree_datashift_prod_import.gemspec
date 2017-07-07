# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_datashift_prod_import'
  s.version     = '3.0.0'
  s.summary     = 'Datashift Prod Import'
  s.description = 'Datashift Prod Import'
  s.required_ruby_version = '>= 2.0.0'

  s.authors    =  ['Nimish Gupta', 'Pikender Sharma', '+Vinsol Team']
  s.email     = 'info@vinsol.com'
  s.homepage  = 'http://vinsol.com'

  s.files       = `git ls-files`.split("\n")
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency('spree_core', '~> 3.0.0')
  s.add_dependency 'datashift'
  s.add_dependency 'datashift_spree'

  s.add_development_dependency 'capybara', '~>2.14.4'
  s.add_development_dependency 'coffee-rails', '~>4.2'
  s.add_development_dependency 'database_cleaner', '~>1.6.1'
  s.add_development_dependency 'factory_girl', '~>4.8.0'
  s.add_development_dependency 'ffaker', '~>1.32.1'
  s.add_development_dependency 'rspec-rails', '~>3.6.0'
  s.add_development_dependency 'sass-rails', '~>5.0.0'
  s.add_development_dependency 'selenium-webdriver', '~>3.4.3'
  s.add_development_dependency 'simplecov', '~>0.14.1'
  s.add_development_dependency 'sqlite3', '~>1.3.13'
  s.add_development_dependency 'shoulda-matchers', '~>3.1.0'
  s.add_development_dependency 'rspec-activemodel-mocks', '~>1.0.3'
end
