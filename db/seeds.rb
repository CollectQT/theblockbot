list1 = BlockList.create(name: 'Bad Cats')
list2 = BlockList.create(name: 'Dogs')
list3 = BlockList.create(name: 'Birbs')

me = User.get(TwitterClient.REST.user)
Report.parse('@lynncyrin #block +cyrin_test_2 #badcats knocked over my water', me)

Subscription.create(user_id: me.id, block_list_id: list1.id)
Subscription.create(user_id: me.id, block_list_id: list2.id)
