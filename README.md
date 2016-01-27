# TheBlockBot

## Requirements

 * Rails
 * Twitter API keys
 * Postgres
 * Redis
 * Foreman

## Start

`$ foreman start`

## Production Requirements

The following environment variables:

[Twitter](https://apps.twitter.com/)
 * `twitter_consumer_key`
 * `twitter_consumer_secret`
 * `twitter_access_token`
 * `twitter_access_token_secret`

Postgres
 * `PG_URL` or `DATABASE_URL`

Redis
 * `REDIS_URL`

Sidekiq
 * `SIDEKIQ_USERNAME`
 * `SIDEKIQ_PASSWORD`
