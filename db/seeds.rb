list1 = BlockList.create(name: 'Bad Cats')
list2 = BlockList.create(name: 'Dogs')
list3 = BlockList.create(name: 'Birbs')

me = User.get(TwitterClient.REST.user)

Subscription.to(list1.id, me.id)
Subscription.to(list2.id, me.id)

Report.parse('@lynncyrin #block #badcats knocked over my water')
