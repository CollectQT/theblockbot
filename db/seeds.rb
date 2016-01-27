me = User.get(TwitterClient.REST.user)

list1 = BlockList.create(name: 'Bad Cats', description: 'mostly they knocked things over')
list2 = BlockList.create(name: 'Dogs', description: 'v smells', hidden: true)
list3 = BlockList.create(name: 'Birbs', description: 'stole all the bread')

Blocker.create(block_list: list1, user: me)
Admin.create(block_list: list2, user: me)

Report.parse('@lynncyrin #block +cyrin_test_2 #badcats knocked over my water', me)

Subscription.create(user: me, block_list: list1)
Subscription.create(user: me, block_list: list2)
