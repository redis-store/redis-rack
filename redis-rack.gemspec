# -*- encoding: utf-8 -*-

require_relative 'lib/redis/rack/version'

Gem::Specification.new do |s|
  s.name        = 'redis-rack'
  s.version     = Redis::Rack::VERSION
  s.authors     = ['Luca Guidi']
  s.email       = ['me@lucaguidi.com']
  s.homepage    = 'http://redis-store.org/redis-rack'
  s.summary     = %q{Redis Store for Rack}
  s.description = %q{Redis Store for Rack applications}
  s.license     = 'MIT'

  s.files = `git ls-files`.split("\n")

  s.add_dependency 'redis-store',   ['< 2', '>= 1.2']
  s.add_dependency 'rack-session',  '>= 0.2.0'
end
