require 'rack/session/abstract/id'
require 'redis-store'
require 'thread'
require 'redis/rack/connection'

module Rack
  module Session
    class Redis < Abstract::ID
      attr_reader :mutex

      DEFAULT_OPTIONS = Abstract::ID::DEFAULT_OPTIONS.merge(
        :redis_server => 'redis://127.0.0.1:6379/0/rack:session'
      )

      def initialize(app, options = {})
        super

        @mutex = Mutex.new
        @conn = ::Redis::Rack::Connection.new(@default_options)
      end

      def generate_unique_sid(session)
        return generate_sid if session.empty?
        loop do
          sid = generate_sid
          first = with do |c|
            [*c.setnx(sid, session, @default_options)].first
          end
          break sid if [1, true].include?(first)
        end
      end

      def get_session(env, sid)
        if env['rack.session.options'][:skip]
          [generate_sid, {}]
        else
          with_lock(env, [nil, {}]) do
            unless sid and session = with { |c| c.get(sid) }
              session = {}
              sid = generate_unique_sid(session)
            end
            [sid, session]
          end
        end
      end

      def set_session(env, session_id, new_session, options)
        with_lock(env, false) do
          with { |c| c.set session_id, new_session, options }
          session_id
        end
      end

      def destroy_session(env, session_id, options)
        with_lock(env) do
          with { |c| c.del(session_id) }
          generate_sid unless options[:drop]
        end
      end

      def threadsafe?
        @default_options.fetch(:threadsafe, true)
      end

      def with_lock(env, default=nil)
        @mutex.lock if env['rack.multithread'] && threadsafe?
        yield
      rescue Errno::ECONNREFUSED
        if $VERBOSE
          warn "#{self} is unable to find Redis server."
          warn $!.inspect
        end
        default
      ensure
        @mutex.unlock if @mutex.locked?
      end

      def with(&block)
        @conn.with(&block)
      end
    end
  end
end
