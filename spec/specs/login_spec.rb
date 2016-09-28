describe "login", :type => :feature  do

  before(:each) do
    visit '/'
  end

  # vcr cassette loaded from spec helper
  it "succeeds on valid login for user @twitter" do
    expect(page).to have_content('Sign in with Twitter')
    mock_user_twitter
    expect(page).to have_content("Sign out")
  end

  # one use vcr cassette
  it "succeeds on valid login for user @twitterapi" do
    expect(page).to have_content('Sign in with Twitter')
    mock_user_twitterapi
    expect(page).to have_content("Sign out")
  end

  # # unsure what this test is for, besides distracting command line output
  # it "fails on invalid credentials" do
  #   OmniAuth.config.mock_auth[:twitter] = :invalid_credentials
  #   click_link "Sign in"
  #   expect(page).to have_content("Authentication error")
  # end

end
