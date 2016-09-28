require 'flt'
require 'vcr'
require 'json'
require 'hash_dot'
require 'omniauth'
require 'webmock/rspec'
require 'database_cleaner'
require 'factory_girl_rails'


OmniAuth.config.test_mode = true
WebMock.disable_net_connect!(allow_localhost: true)


def mock_omniauth()
  OmniAuth.config.mock_auth[:twitter] = nil
  Rails.application.env_config["omniauth.auth"] =
    OmniAuth.config.mock_auth[:twitter]
end


def mock_user(account_id, display_name)
  # ex: user_mock(783214, 'Twitter')
  OmniAuth.config.add_mock(:twitter, {
    :provider => 'twitter',
    :name => display_name,
    :extra => { :raw_info => { :id => account_id } },
    :credentials => {:token => 'token', :secret => 'secret'},
  })
end


def mock_user_ENV_user()
  user = User.get_from_ENV
  mock_user(user.account_id, user.name)
end


VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :webmock
  c.configure_rspec_metadata!

  c.default_cassette_options = {
    :record => :new_episodes,
    :match_requests_on => [ :method, :path, :query ]
  }

  c.before_record do |r|
    r.request.headers.except!(
      "Authorization","Accept-Encoding"
    )
    r.response.headers.except!(
      "Server", "Set-Cookie", "X-Connection-Hash", "X-Transaction",
      "Cache-Control", "Content-Length", "Date", "Expires", "Last-Modified",
      "Pragma", "Strict-Transport-Security", "X-Access-Level",
      "X-Content-Type-Options", "X-Frame-Options", "X-Rate-Limit-Remaining",
      "X-Rate-Limit-Reset", "X-Response-Time", "X-Twitter-Response-Tags",
      "X-Xss-Protection", "Content-Disposition", "Content-Type",
    )
  end
end


RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)

    begin
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end

end
