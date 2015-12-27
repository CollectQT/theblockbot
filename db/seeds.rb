# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

list1 = BlockList.create(name: 'Bad Cats')
list2 = BlockList.create(name: 'Smelly Dogs')
list3 = BlockList.create(name: 'Flitty Birbs')

me = User.get(TwitterClient.REST.user)

subscribe = Subscription.to(list1.id, me.id)
subscribe = Subscription.to(list2.id, me.id)
