describe "logins", :type => :feature  do

  let(:mock_auth_hash) {
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      :extra => { :raw_info => { :id => 1234 } },
      :credentials => {
        :token => 'mock_token',
        :secret => 'mock_secret',
      },
    })
  }

  before(:each) do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:twitter] = nil
    Rails.application.env_config["omniauth.auth"] =
      OmniAuth.config.mock_auth[:twitter]
    visit '/'
  end

  it "succeeds on valid credentials" do
    expect(page).to have_content("Sign in with Twitter")
    mock_auth_hash
    click_link "Sign in"
    expect(page).to have_content("mockusername")
    expect(page).to have_content("Sign out")
  end

  it "fails on invalid credentials" do

    OmniAuth.config.on_failure = Proc.new { |env|
      OmniAuth::FailureEndpoint.new(env).redirect_to_failure
    }
    OmniAuth.config.mock_auth[:twitter] = :invalid_credentials

  end

end
