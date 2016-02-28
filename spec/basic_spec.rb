RSpec.describe do
  describe "TheBlockBot" do

    it "can run tests" do
      expect(0).to eq(0)
    end

    it "should start with no users" do
      all_users = User.all.count
      expect(all_users).to eq(0)
    end

  end
end
