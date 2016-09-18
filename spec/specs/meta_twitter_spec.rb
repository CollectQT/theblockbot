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

  let (:stub_get_connections) {
    allow(MetaTwitter).to receive(:get_connections) do |user, ids|
      ids.map { |id|
        case id
          when 1 then {'id': id, 'connections': 'none'}.to_dot
          when 2 then {'id': id, 'connections': 'following'}.to_dot
        end
      }.compact
    end
  }

  context "MetaTwitter::RemoveFollowing.from_list" do
    it "removes following for list" do
      stub_get_connections

      list = MetaTwitter::RemoveFollowing.new.from_list(nil, [1, 2])
      expected_list = [1]

      expect(list).to eq(expected_list)
    end

    it "respects the `max` parameter" do
      stub_get_connections

      expect(MetaTwitter).to receive(:get_connections).with(nil, [1])
      expect(MetaTwitter).to receive(:get_connections).with(nil, [2])

      MetaTwitter::RemoveFollowing.new.from_list(nil, [1, 2], max: 1)
    end
  end

end
