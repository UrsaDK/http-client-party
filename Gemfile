# frozen_string_literal: true

ruby File.read('.ruby-version').strip
source 'https://rubygems.org'

gem 'httparty'
gem 'openssl'

# bundle --without development --without test
%i[development test].tap do |groups|
  gem 'pry', group: groups, require: true
  gem 'pry-byebug', group: groups, require: false
end

# bundle --without test
group :test do
  gem 'rubocop', require: false             # Static code analyser
  gem 'rubocop-performance', require: false # Performance optimization analysis
  gem 'simplecov', require: false           # Code coverage report generator
end
