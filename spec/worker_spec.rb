describe "create_blocks_from_report" do

  let(:worker) { CreateBlocksFromReport.new }
  let(:report) { instance_double(Report, id: 1, block_list:
      instance_double(BlockList, users: [
        instance_double(User, id: 1),
        instance_double(User, id: 1),
        instance_double(User, id: 1),
      ])
  )}

  it "starts a create_block for every user on the report" do
    expect(worker).to receive(:block).exactly(3).times
    worker.work(report)
  end

end
