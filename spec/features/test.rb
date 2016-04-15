describe "Twitter", :type => :feature do

  before do
    Capybara.current_driver = :mechanize
  end

  it "loads with our driver" do
    visit 'https://twitter.com/login'
    expect(page).to have_title "Login on Twitter"
  end

  it "can be logged into" do
    visit 'https://twitter.com/login'
    find(".js-username-field").set(ENV['twitter_username'])
    find(".js-password-field").set(ENV['twitter_password'])
    find(".signin-wrapper .submit").click
    expect(page).to have_title "Twitter"
  end

  it "allows an oauth login with TheBlockBot" do
    visit '/'
    expect(page).to have_title "TheBlockBot"
    click_link('Sign in with Twitter')
    find("#username_or_email").set(ENV['twitter_username'])
    find("#password").set(ENV['twitter_password'])
    find("#oauth_form .submit.selected").click
  end

  it "starts with the test account (@cyrin_test_2) unblocked" do
    # use the gem for this
  end

end


describe "TheBlockBot", :type => :feature do

  it "loads with our driver" do
    visit '/'
    expect(page).to have_title "TheBlockBot"
  end

  it "allows you to subscribe to a test block list (#TestNoExpire)" do
  end

  it "blocks the test account when you subscribe" do
  end

  it "allows you to unsubscribe from a block list" do
  end

  it "keeps a log of subscription changes" do
  end

  it "unblocks the test account when you unsubscribe" do
  end

  it "keeps a log of blocks and unblocks" do
  end

  it "allows you to create a block list" do
  end

  it "allows you to create a report" do
  end

  it "informs you of incorrectly formatted reports" do
  end

  it "keeps a log of created reports" do
  end

  it "shows admin commands for admins" do
  end

  it "shows pending reports on the reports page" do
  end

  it "allows admins to approve reports" do
  end

  it "keeps a log of approved reports" do
  end

  it "allows admins of a block list to add other admins" do
  end

  it "allows admins of a block list to add other blockers" do
  end

end
