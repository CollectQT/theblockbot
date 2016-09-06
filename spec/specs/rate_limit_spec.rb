### CODE WIP !!! ###

# describe "the login callback", :type => :request  do

#   let(:limit) { 15 }
#   let(:route) { '/auth/twitter/callback' }

#   def user_mock(account_id, display_name)
#     OmniAuth.config.add_mock(:twitter, {
#       :provider => 'twitter',
#       :name => display_name,
#       :extra => { :raw_info => { :id => account_id } },
#       :credentials => {:token => 'token', :secret => 'secret'},
#     })
#   end

#   before(:each) do
#     Rack::Attack.clear!
#     OmniAuth.config.mock_auth[:twitter] = nil
#     Rails.application.env_config["omniauth.auth"] =
#       OmniAuth.config.mock_auth[:twitter]
#     user_mock(783214, 'Twitter')
#   end

#   it "should return 500 below the rate limit", :vcr do
#     get route
#     expect(response.status).to eq 500
#   end

#   it "should return 429 above the rate limit", :vcr do
#     (limit*2).times do |i|
#       get route
#       expect(response.status).to eq 429 if i > limit
#     end
#   end

# end
