# Redis stores for Rack

__`redis-rack`__ provides a Redis backed session store __Rack__. See the main [redis-store readme](https://github.com/redis-store/redis-store) for general guidelines.

## Installation

```ruby
# Gemfile
gem 'redis-rack'
```

### Usage

If you are using redis-store with Rails, consider using the [redis-rails gem](https://github.com/redis-store/redis-rails) instead. For standalone usage:

```ruby
# config.ru
require 'rack'
require 'rack/session/redis'

use Rack::Session::Redis
```

## Running tests

```shell
gem install bundler
git clone git://github.com/redis-store/redis-rack.git
cd redis-rack
bundle install
bundle exec rake
```

If you are on **Snow Leopard** you have to run `env ARCHFLAGS="-arch x86_64" bundle exec rake`

## Copyright

(c) 2009 - 2013 Luca Guidi - [http://lucaguidi.com](http://lucaguidi.com), released under the MIT license
