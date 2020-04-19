require 'minitest/autorun'
require_relative '../lib/database'

class DatabaseTest < Minitest::Test

  def setup
    @db = Database.new(ENV['REDIS_HOST'], ENV['REDIS_PORT'])
  end

  def test_connection
    assert @db
  end

  def test_save_container
    assert @db.save_container("lxd:key_test", 10, state: {status: 'test'}, info: {status: 'test'})
  end
  
end