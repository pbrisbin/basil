require 'test_helper'

class BroadcastTest < Test::Unit::TestCase
  include Basil

  def test_broadcast
    msg = nil
    txt = 'some test text'

    Broadcast.on(:broadcast_received) do |m|
      msg = m
      raise StopListening
    end

    send_broadcast(txt)

    require 'timeout'
    Timeout::timeout(10) do
      while !msg
        sleep 0.1
      end
    end

    assert_equal :all, msg.to
    assert_nil msg.from
    assert_nil msg.from_name
    assert_equal txt + "\n", msg.text
  end

  private

  def send_broadcast(text)
    require 'socket'

    Socket.tcp(Config.broadcast_host, Config.broadcast_port) do |socket|
      socket.puts(text)
      socket.close_write
    end
  end
end
