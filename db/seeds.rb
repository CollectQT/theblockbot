admin = User.get_from_ENV

block_list = BlockList.make(
  name: 'Testing12',
  user: admin,
  description: 'for testing, maintenence, etc',
  expires: nil,
  showcase: false,
)

Admin.find_or_create_by(
  :block_list => block_list,
  :user       => admin,
)

Report.parse_objects(
  block_list: block_list,
  target:     admin,
  text:       'Global parent report, used for reference purposes',
  reporter:   admin,
)
