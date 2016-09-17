describe "meta_twitter" do

  let(:env_user) { MetaTwitter::Auth.config( User.get_from_ENV ) }

  context "MetaTwitter::ReadFollows.from_followers" do
    it "reads roughly the same amount of followers as followers_count", :vcr do
      follows          = MetaTwitter::ReadFollows.from_followers( env_user, target: '@gitlab' )
      rounded_follows  = Flt.DecNum(follows.count).round(precision: 1)
      follow_count     = TwitterClient.user('@gitlab').followers_count
      rounded_count    = Flt.DecNum(follow_count).round(precision: 1)

      expect(rounded_follows).to eq(rounded_count)
    end
  end

end
