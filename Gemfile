source "https://rubygems.org"

group :test, optional: true do
  gem 'rake', '~> 10.1.1'
  gem 'rspec'
  gem 'rdoc', RUBY_VERSION <= '2.2.2' ? '5.1.0': '>5.1.0'
  gem 'pry'
  gem 'addressable', '~>2.3.8'
  gem 'webmock', RUBY_VERSION <= '1.9.3' ? '2.3.2': '>2.3.2'
  gem 'capistrano', ENV['CAP_2_TEST'] == 'true' ? '~> 2.15.0': '~> 3.9.0'
end

group :bugsnag, optional: true do
  gem 'bugsnag', '~> 6.0'
end

gemspec
