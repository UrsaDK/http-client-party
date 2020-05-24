source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

gem 'httparty'
gem 'openssl'

# bundle --without development --without tests
gem 'pry', group: %i[development tests], require: true
gem 'pry-byebug', group: %i[development tests], require: false
gem 'pry-rails', group: %i[development tests], require: true

# bundle --without tests
group :tests do
  gem 'rubocop', require: false             # Static code analyser
  gem 'rubocop-performance', require: false # Performance optimization analysis
  gem 'simplecov', require: false           # Code coverage report generator
end
