admin = User.get_from_ENV

block_list = BlockList.find_or_create_by(name: 'Testing12')
block_list.update_attributes(
  :description  => 'for testing, maintenence, etc',
  :expires      => nil,
)

Admin.find_or_create_by(
  :block_list => block_list,
  :user       => admin,
)

# was getting weird argument errors?
Report.parse_objects(block_list, admin, 'Global parent report, used for reference purposes', admin)
