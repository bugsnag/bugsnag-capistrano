source "https://rubygems.org"

# Any :development dependencies are ignored for license auditing purposes
group :development do
end

# Any :test dependencies are ignored for license auditing purposes
group :test, optional: true do
  gem 'rake', '~> 10.1.1'
  gem 'rspec'
  gem 'rdoc'
  gem 'pry'
  gem 'addressable', '~>2.3.8'
  gem 'webmock', RUBY_VERSION <= '1.9.3' ? '2.3.2': '>2.3.2'
  gem 'capistrano', ENV['CAP_2_TEST'] == 'true' ? '~> 2.15.0': '~> 3.9.0'
end

gemspec
