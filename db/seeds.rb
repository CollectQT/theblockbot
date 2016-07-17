admin = User.get_from_ENV

block_list = BlockList.create(
  :name         => 'Testing12',
  :description  => 'for testing, maintenence, etc',
  :expires      => nil,
)

Admin.create(
  :block_list => block_list,
  :user       => admin,
)

# was getting weird argument errors?
Report.parse_objects(block_list, admin, 'Global parent report, used for reference purposes', admin)
