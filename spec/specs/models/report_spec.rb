describe "Report" do

  let(:user) { User.get_from_ENV }
  let(:block_list) {
    block_list = BlockList.create(name: 'testlist')
    Admin.create(user: user, block_list: block_list)
    block_list
  }
  let(:report_parent) { Report.parse_objects(
    block_list: block_list,
    target: user,
    text: 'parent report',
    reporter: user,
  ) }
  let(:report_child) { Report.parse_objects(
    block_list: BlockList.first,
    target: user,
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

    it 'sets parent attribute on child reports' do
      expect(report_child.parent.id).to be(report_parent.id)
    end

    it 'sets the parent_id=1 on parent reports' do
      expect(report_parent.parent_id).to be(1)
    end

    it 'does not set parent_id=1 on child reports' do
      expect(report_child.parent_id).not_to be(1)
    end
  end

end
