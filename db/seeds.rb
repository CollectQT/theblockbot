# For testing! Not actual seed values!

me = User.get(TwitterClient.REST.user)

list1 = BlockList.create(
  name: 'Bad Cats',
  description: 'mostly they knocked things over',
  expires: 365)
list2 = BlockList.create(
  name: 'Dogs',
  description: 'v smells',
  expires: nil)
list3 = BlockList.create(
  name: 'Birbs',
  description: 'stole all the bread, list is softblocks only',
  expires: 0,
  showcase: true)

Admin.create(block_list: list1, user: me)
Admin.create(block_list: list2, user: me)
Admin.create(block_list: list3, user: me)

Subscription.add(me.id, list1.id)
Subscription.add(me.id, list2.id)
Subscription.add(me.id, list3.id)

Report.parse('@lynncyrin #block +cyrin_test_2 #badcats knocked over my water', me)
Report.parse('@lynncyrin #block +cyrin_test_2 #dogs knocked over my water', me)
Report.parse('@lynncyrin #block +cyrin_test_2 #birbs knocked over my water', me)
