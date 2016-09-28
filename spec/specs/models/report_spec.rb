describe "Report" do

  let(:user) { User.get_from_ENV }
  let(:block_list) {
    block_list = BlockList.create(name: 'testlist')
    Admin.create(user: user, block_list: block_list)
    block_list
  }
  let(:report_parent) { Report.parse_objects(
    block_list: block_list,
    target: User.first,
    text: 'parent report',
    reporter: user,
  ) }
  let(:report_child) { Report.parse_objects(
    block_list: BlockList.first,
    target: User.first,
    text: 'child report',
    reporter: user,
    parent_id: report_parent.id,
  ) }

  context 'parse_objects' do
    it 'creates a report' do
      expect(report_parent.id).to be_a(Integer)
    end

    it 'auto approves reports' do
      expect(report_parent.approver).to be(user)
    end
  end

end
