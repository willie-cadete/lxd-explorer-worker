require 'minitest/autorun'
require_relative '../lib/lxd'

class LxdServerTest < Minitest::Test

  def setup
    @lxd = Lxd.new('wcl-lxd-fake-api.herokuapp.com:443','','')
  end

  def test_list_containers
    assert_instance_of Array, @lxd.get_containers
  end
  
  def test_container_info
    container = @lxd.get_containers[0]
    assert_instance_of Hash, @lxd.get_container_info(container)
  end

  def test_container_state
    container = @lxd.get_containers[0]
    assert_instance_of Hash, @lxd.get_container_info(container)
  end

end