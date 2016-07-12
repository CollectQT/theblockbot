me = User.get(TwitterClient.REST.user)

list_1 = BlockList.create(
  name: 'TestNoExpire',
  description: 'for testing and maintenence',
  expires: nil,)
list_2 = BlockList.create(
  name: 'TestSoftBlocks',
  description: 'for testing and maintenence',
  expires: 0,)

Admin.create(block_list: list_1, user: me)
Admin.create(block_list: list_2, user: me)

Report.parse('@lynncyrin #block +cyrin_test_2 #testsoftblocks testing', me)
Report.parse('@lynncyrin #block +cyrin_test_2 #testnoexpire testing', me)
