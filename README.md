# TheBlockBot

live site: <http://theblockbot.herokuapp.com>
repo: <https://gitlab.com/collectqt/theblockbot>

## Requirements

 * Rails
 * Twitter API keys
 * Postgres
 * Redis
 * Foreman

## Start

**Main application:**

`$ foreman start`

**Cron job (`crontab -e`) for unblocks:**

`00 * * * * cd /home/lynn/theblockbot/ && /usr/share/rvm/rubies/ruby-2.2.1/bin/rake RAILS_ENV=development sidekiq:unblock_processor`

on Heroku its

`$ rake sidekiq:unblock_processor`

## Production Requirements

The following environment variables:

Secret key
* `SECRET_KEY_BASE`

[Twitter](https://apps.twitter.com/)
 * `twitter_consumer_key`
 * `twitter_consumer_secret`
 * `twitter_access_token`
 * `twitter_access_token_secret`

Postgres
 * `DATABASE_URL`

Redis
 * `REDIS_URL`

Sidekiq
 * `SIDEKIQ_USERNAME`
 * `SIDEKIQ_PASSWORD`

## Tests

    $ bin/rspec spec/features/test.rb
