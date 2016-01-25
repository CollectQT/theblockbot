me = User.get(TwitterClient.REST.user)

list1 = BlockList.create(name: 'Bad Cats')
list2 = BlockList.create(name: 'Dogs', hidden: true)
list3 = BlockList.create(name: 'Birbs')
list4 = BlockList.create(name: 'General')

Blocker.create(block_list: list3, user: me)
Admin.create(block_list: list4, user: me)

Report.parse('@lynncyrin #block +cyrin_test_2 #badcats knocked over my water', me)

Subscription.create(user: me, block_list: list1)
Subscription.create(user: me, block_list: list2)
