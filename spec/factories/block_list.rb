describe "BlockList", :type => :feature  do

  let(:block_list)  { build :block_list }

  it "utilizes factorygirl" do
    expect(block_list.name).to eql('factory test')
  end

end
