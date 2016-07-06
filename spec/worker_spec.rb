describe "create_blocks_from_report" do

  let(:worker) { CreateBlocksFromReport.new }
  let(:report) { instance_double(Report, id: 1, block_list:
    instance_double(BlockList, users: [
      instance_double(User, id: 1),
      instance_double(User, id: 1),
      instance_double(User, id: 1),
    ])
  )}

  it "creates 3 blocks for 3 block list subscribers from an approved report" do
    expect(worker).to receive(:block).exactly(3).times
    worker.work(report)
  end

end


describe "create_blocks_from_subscribe" do

  it "creates 3 blocks for user from 3 previously approved reports" do
  end

end


describe "create_unblocks_from_expire" do
end


describe "create_unblocks_from_unsubscribe" do
end


describe "create_block" do
end
