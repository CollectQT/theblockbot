source 'https://rubygems.org'

ruby "2.2.1"

gem 'rails', '4.2.5'
gem 'pg'

gem 'sass-rails', '~> 5.0'
gem 'twitter-bootstrap-rails'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'twitter', :git => 'https://github.com/sferik/twitter.git', :branch => 'streaming-updates'
gem 'sidekiq'
gem 'sinatra', require: false
gem 'slim'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :production do
  # for heroku
  gem 'rails_12factor'
end
