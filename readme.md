# TheBlockBot

* live site: <http://theblockbot.herokuapp.com>
* repo: <https://gitlab.com/collectqt/theblockbot>
* mirror repo: <https://github.com/collectqt/theblockbot>

## requirements

 * Ruby
 * Redis
 * Postgres
 * Twitter API keys

## quickstart

`$ foreman start` then open <http://localhost:5000/>

## slowstart

```
$ subl .env
    PORT=5000
    SECRET_KEY_BASE=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    # from https://apps.twitter.com
    TWITTER_CONSUMER_KEY=XXXXXXXXXXXXXXXXXXXXXXXXXXX
    TWITTER_CONSUMER_SECRET=XXXXXXXXXXXXXXXXXXXXXXXX
    TWITTER_ACCESS_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXX
    TWITTER_ACCESS_TOKEN_SECRET=XXXXXXXXXXXXXXXXXXXX

$ bundle install
$ bundle exec rake db:drop db:create db:migrate db:seed
$ bundle exec rspec
    # should be all green
$ foreman start
```

## testing

`$ guard` in its own terminal window

`$ bundle exec rspec` if that's doing too much
