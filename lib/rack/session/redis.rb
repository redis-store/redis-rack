require 'rack/session/abstract/id'
require 'redis-store'
require 'thread'
require 'redis/rack/connection'
require 'redis/rack'

module Rack
  module Session
    # Implementation of Rack session storage in Redis for applications
    # that don't depend on ActionDispatch.
    class Redis < Abstract::ID
      include ::Redis::Rack

      attr_reader :mutex

      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge(
        :redis_server => 'redis://127.0.0.1:6379/0/rack:session'
      )
    end
  end
end
