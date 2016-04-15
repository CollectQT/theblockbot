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

end


describe "TheBlockBot", :type => :feature do

  it "loads with our driver" do
    visit '/'
    expect(page).to have_title "TheBlockBot"
  end

  it "allows you to subscribe to a block list" do
    visit '/'
    click_link('Block Lists')

end
