# Redis session store for Rack

[![Gem Version](https://badge.fury.io/rb/redis-rack.png)](http://badge.fury.io/rb/redis-rack)
[![Build Status](https://github.com/redis-store/redis-rack/workflows/CI/badge.svg)](https://github.com/redis-store/redis-rack/actions)
[![Code Climate](https://codeclimate.com/github/redis-store/redis-store.png)](https://codeclimate.com/github/redis-store/redis-rack)

__`redis-rack`__ provides a Redis-backed session store for __Rack__.

See the main [redis-store readme] for general guidelines.

**NOTE:** This is not [redis-rack-cache][], the library for using Redis
as a backend store for the `Rack::Cache` HTTP cache. All this gem does
is store the Rack session within Redis.

## Installation

Install with Bundler by adding the following to Gemfile:

```ruby
gem 'redis-rack'
```

Then, run:

```shell
$ bundle install
```

Or, you can install it manually using RubyGems:

```shell
$ gem install redis-rack
```

## Usage

If you are using redis-store with Rails, consider using the [redis-rails gem](https://github.com/redis-store/redis-rails) instead. For standalone usage:

```ruby
# config.ru
require 'rack'
require 'rack/session/redis'

use Rack::Session::Redis

# Alternatively you can specify options to use:
use Rack::Session::Redis,
  :redis_server => "redis://redis:6379/0",
  :expires_in => 3600 # Seconds. If you are using ActiveSupport you can use 1.hour
```

## Development

To install this gem for development purposes:

```shell
$ gem install bundler # note: you don't need to do this if you already have it installed
$ git clone git://github.com/redis-store/redis-rack.git
$ cd redis-rack
$ bundle install
```

## Running tests

To run tests:

```shell
$ bundle exec rake
```

If you are on **Snow Leopard** you have to run the following command to
build this software:

```shell
$ env ARCHFLAGS="-arch x86_64" bundle exec rake
```

## Copyright

2009 - 2013 Luca Guidi - [http://lucaguidi.com](http://lucaguidi.com), released under the MIT license

[redis-rack-cache]: https://github.com/redis-store/redis-rack-cache
[redis-store readme]: https://github.com/redis-store/redis-store
