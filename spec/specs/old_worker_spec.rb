describe "create_blocks_from_report" do

  let(:worker) { CreateBlocksFromReport.new }
  let(:report) { instance_double(Report, id: 2, block_list:
    instance_double(BlockList, users: [
      instance_double(User, id: 1),
      instance_double(User, id: 1),
      instance_double(User, id: 1),
    ])
  )}

  it "creates 3 blocks for 3 block list subscribers from an approved report" do
    expect(worker).to receive(:block).exactly(3).times.with(1, 2)
    worker.work_on(report)
  end

end


describe "create_blocks_from_subscribe" do

  let(:worker) { CreateBlocksFromSubscribe.new }
  let(:user) { 1 }
  let(:block_list) { instance_double(BlockList, active_reports: [
    instance_double(Report, id: 2),
    instance_double(Report, id: 2),
    instance_double(Report, id: 2),
    ]
  )}

  it "creates 3 blocks for a user from 3 previously approved reports" do
    expect(worker).to receive(:block).exactly(3).times.with(1, 2)
    worker.work_on(user, block_list)
  end

end
