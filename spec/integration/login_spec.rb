describe "login", :type => :feature  do

  before(:each) do
    OmniAuth.config.mock_auth[:twitter] = nil
    Rails.application.env_config["omniauth.auth"] =
      OmniAuth.config.mock_auth[:twitter]
    visit '/'
  end

  def user_mock(account_id, display_name)
    OmniAuth.config.add_mock(:twitter, {
      :provider => 'twitter',
      :name => display_name,
      :extra => { :raw_info => { :id => account_id } },
      :credentials => {:token => 'token', :secret => 'secret'},
    })
  end

  def test_login(setup_user)
    expect(page).to have_content("Sign in with Twitter")
    user = setup_user
    click_link "Sign in"
    expect(page).to have_content(user.name)
    expect(page).to have_content("Sign out")
  end

  it "succeeds on valid login for user @twitter", :vcr do
    test_login( user_mock(783214, 'Twitter') )
  end

  it "succeeds on valid login for user @twitterapi", :vcr do
    test_login( user_mock(6253282, 'Twitter API') )
  end

  it "fails on invalid credentials" do
    OmniAuth.config.mock_auth[:twitter] = :invalid_credentials
    click_link "Sign in"
    expect(page).to have_content("Authentication error")
  end

end
