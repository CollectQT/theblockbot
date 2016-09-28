describe "login", :type => :feature  do

  before(:each) do
    mock_omniauth
    visit '/'
  end

  def test_login(setup_user)
    expect(page).to have_content("Sign in with Twitter")
    user = setup_user
    click_link "Sign in"
    expect(page).to have_content(user.name)
    expect(page).to have_content("Sign out")
  end

  it "succeeds on valid login for user @twitter", :vcr do
    test_login( mock_user(783214, 'Twitter') )
  end

  it "succeeds on valid login for user @twitterapi", :vcr do
    test_login( mock_user(6253282, 'Twitter API') )
  end

  # # unsure what this test is for, besides distracting command line output
  # it "fails on invalid credentials" do
  #   OmniAuth.config.mock_auth[:twitter] = :invalid_credentials
  #   click_link "Sign in"
  #   expect(page).to have_content("Authentication error")
  # end

end
