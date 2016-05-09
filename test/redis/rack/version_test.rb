require 'test_helper'

describe Redis::Rack::VERSION do
  it 'returns current version' do
    Redis::Rack::VERSION.must_equal '2.0.0.pre'
  end
end
