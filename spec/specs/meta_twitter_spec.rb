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

  let (:remove_following) {
    obj = MetaTwitter::RemoveFollowing.new
    obj.stub(:get_connections) do |arg1, arg2|
      arg2.map {|id|
        case
          when id.eql?(1) then {'id': id, 'connections': 'none'}.to_dot
          when id.eql?(2) then {'id': id, 'connections': 'following'}.to_dot
        end
      }.compact
    end
    return obj
  }

  context "MetaTwitter::RemoveFollowing.from_list" do
    it "removes following for list" do
      list = remove_following.from_list(nil, [1, 2])
      expected_list = [1]

      expect(list).to eq(expected_list)
    end

    it "respects the `max` parameter" do
      expect(remove_following).to receive(:get_connections).with(nil, [1])
      expect(remove_following).to receive(:get_connections).with(nil, [2])

      remove_following.from_list(nil, [1, 2], max: 1)
    end
  end

end
