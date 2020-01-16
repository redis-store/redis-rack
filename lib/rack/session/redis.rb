require 'rack/session/abstract/id'
require 'redis-store'
require 'thread'
require 'redis/rack/connection'

module Rack
  module Session
    class Redis < Abstract::PersistedSecure
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
            [*c.setnx(sid.private_id, session, @default_options)].first
          end
          break sid if [1, true].include?(first)
        end
      end

      def find_session(req, sid)
        if req.session.options[:skip]
          [generate_sid, {}]
        else
          with_lock(req, [nil, {}]) do
            unless sid and session = get_session_with_fallback(sid)
              session = {}
              sid = generate_unique_sid(session)
            end
            [sid, session]
          end
        end
      end

      def write_session(req, session_id, new_session, options)
        if threadsafe?
          return transactional_write_session(req, session_id, new_session, options)
        end

        with { |c| c.set session_id, new_session, options }
        session_id
      end

      def transactional_write_session(req, session_id, new_session, options)
        with { |c|
          # Atomically read the old session and merge it with the new session
          # Inspired by this: https://stackoverflow.com/a/11311126/7816
          loop do
            c.watch session_id
            old_session = c.get(session_id) || {}

            break if c.multi do |multi|
              # Using Hash#merge to merge the old and new session is a naïve
              # strategy which does not always produce the correct result.
              #
              # Specifically, if a different request removes a key from the
              # session in the time between when session was intially read
              # by the current request and the time when it gets written back,
              # the deleted keys will reappear.
              #
              # Solving this requires determining the intended changes
              # (insertions/updates/deletions) and selectively applying them,
              # when writing the session. To accomplish that, we must make a
              # copy of the initial state of the session at the beginning of
              # the request, which we can then later compare with the updated
              # state.
              #
              # One might also consider doing a deep merge of the existing and
              # the updated session.
              multi.set session_id, old_session.merge(new_session), options
            end
          end
        }
        session_id
      end

      def delete_session(req, sid, options)
        with_lock(req) do
          with do |c|
            c.del(sid.public_id)
            c.del(sid.private_id)
          end
          generate_sid unless options[:drop]
        end
      end

      def threadsafe?
        @default_options.fetch(:threadsafe, true)
      end

      def with_lock(req, default=nil)
        @mutex.lock if req.multithread? && threadsafe?
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

      private

      def get_session_with_fallback(sid)
        with { |c| c.get(sid.private_id) || c.get(sid.public_id) }
      end
    end
  end
end
