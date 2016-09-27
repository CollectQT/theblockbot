describe "BlockList", :type => :feature  do

  let(:block_list_test)  { build :block_list, name: 'factory test' }

  it "utilizes factorygirl" do
    expect(block_list_test.name).to eql('factory test')
  end

end
