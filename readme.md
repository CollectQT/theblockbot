# TheBlockBot

live site: <http://theblockbot.herokuapp.com>

repo: <https://gitlab.com/collectqt/theblockbot>

(mirror repo at <https://github.com/collectqt/theblockbot>)

## requirements

 * Ruby
 * Redis (does the gem take care of this? idk)
 * Postgres (same as above)
 * Twitter API keys

## quickstart

`$ foreman start`, then open <http://localhost:5000/>

## slowstart

```
$ cp example.env .env
$ subl .env # fill with your information from https://apps.twitter.com
$ foreman start
```

## Tests

    $ spring rspec
