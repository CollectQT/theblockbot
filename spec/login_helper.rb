require 'omniauth'
require 'webmock/rspec'


OmniAuth.config.test_mode = true
WebMock.disable_net_connect!(allow_localhost: true)


def mock_user(account_id, display_name)
  # ex: user_mock(783214, 'Twitter')
  OmniAuth.config.mock_auth[:twitter] = nil
  Rails.application.env_config["omniauth.auth"] =
    OmniAuth.config.mock_auth[:twitter]

  VCR.use_cassette("mock_user_#{display_name}") do
    OmniAuth.config.add_mock(:twitter, {
      :provider => 'twitter',
      :name => display_name,
      :extra => { :raw_info => { :id => account_id } },
      :credentials => {:token => 'token', :secret => 'secret'},
    })

    visit '/'
    click_link 'Sign in'
  end
end


def mock_user_twitter()
  mock_user(783214, 'Twitter')
end


def mock_user_twitterapi()
  mock_user(6253282, 'Twitter API')
end
