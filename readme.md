# TheBlockBot

* live site: <http://theblockbot.herokuapp.com>
* repo: <https://gitlab.com/collectqt/theblockbot>
* mirror repo: <https://github.com/collectqt/theblockbot>

## requirements

 * Ruby
 * Redis (does the gem take care of this? idk)
 * Postgres (same as above)
 * Twitter API keys

## quickstart

`$ foreman start` then open <http://localhost:5000/>

## slowstart

```
$ subl .env
    PORT=5000
    SECRET_KEY_BASE=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

    # from https://apps.twitter.com
    twitter_consumer_key=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    twitter_consumer_secret=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    twitter_access_token=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
    twitter_access_token_secret=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

$ spring rspec
    # should be all green
$ foreman start
```

## testing

`$ guard` in its own terminal window

`$ spring rspec` if that's doing too much
