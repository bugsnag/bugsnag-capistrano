source "https://rubygems.org"

group :test, optional: true do
  gem 'rake', '>= 12.3.3', '< 13'
  gem 'rspec'
  gem 'rdoc'
  gem 'pry'
  gem 'addressable', RUBY_VERSION < '2.2' ? '2.8.0' : '2.9.0'
  gem 'webmock', RUBY_VERSION <= '1.9.3' ? '2.3.2': '>2.3.2'
  gem 'capistrano', ENV['CAP_2_TEST'] == 'true' ? '~> 2.15.0': '~> 3.9.0'

  # WEBrick is no longer in the stdlib in Ruby 3.0
  gem 'webrick' if RUBY_VERSION >= '3.0.0'
  gem 'rexml', '< 3.2.5' if RUBY_VERSION == '2.0.0'
  # psych 5.x changed safe_load signature, incompatible with RubyGems < 3.2.3 on older Rubies
  gem 'psych', '< 5.0' if RUBY_VERSION < '2.6'
  # i18n added a call to Module#using in 1.3.0, which doesn't exist until Ruby 2.1
  gem 'i18n', '< 1.3.0' if RUBY_VERSION == '2.0.0'
end

gemspec
