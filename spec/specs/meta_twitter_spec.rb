describe "MetaTwitter" do

  let(:env_user) { MetaTwitter::Auth.config( User.get_from_ENV ) }

  context ".get_followers" do
    it "reads roughly the same amount of followers as followers_count", :vcr do
      follows          = MetaTwitter.get_followers( env_user, target: '@gitlab' )
      rounded_follows  = Flt.DecNum(follows.count).round(precision: 1)
      follow_count     = TwitterClient.user('@gitlab').followers_count
      rounded_count    = Flt.DecNum(follow_count).round(precision: 1)

      expect(rounded_follows).to eq(rounded_count)
    end
  end

  it ".too_many_followers?", :vcr do
    result = MetaTwitter.too_many_followers?(env_user, '@twitter')
    expect(result).to be(true)
  end

end
