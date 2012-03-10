require 'test_helper'

class TestUtils< Test::Unit::TestCase
  include Basil
  include Basil::Utils

  def setup
    @msg = Message.new(Config.me, "Someone", "Some one", "some message text")
  end

  def test_says_is_to_noone
    msg = says("some message text")
    assert_nil msg.to
  end

  def test_replies_is_a_reply
    msg = replies("some message text")
    assert_equal @msg.from_name, msg.to
  end

  def test_says_and_replies_accept_string
    [:says, :replies].each do |meth|
      a_message = "some message text"

      msg = send(meth, a_message)

      assert_equal a_message, msg.text
    end
  end

  def test_says_and_replies_use_block
    [:says, :replies].each do |meth|
      msg = send(meth) do |out|
        out << "line 1"
        out << "line 2"
      end

      assert_equal "line 1\nline 2", msg.text
    end
  end

  def test_says_and_replies_use_block_with_title
    [:says, :replies].each do |meth|
      msg = send(meth, "title") do |out|
        out << "line 1"
        out << "line 2"
      end

      assert_equal "title\nline 1\nline 2", msg.text
    end
  end

  def test_forwards_forwards
    new_to = "Whoever"

    msg = forwards_to(new_to)
    assert_equal new_to, msg.to
  end

  def test_escape_strips_and_uses_cgi
    require 'cgi'

    CGI.expects(:escape).with("a string").returns("a string")
    assert_equal "a string", escape(" a string  ")
  end

  def test_get_http_with_url
    ['http', 'https'].each do |http|
      lib = "net/#{http}"
      url = "#{http}://google.com"
      uri = URI.parse(url)

      require lib

      Net::HTTP.expects(:get_response).with(uri)

      get_http(url)
    end
  end

  def test_get_http_with_options_hash
    # TODO
  end

  # Note: this also tests parse_http
  def test_get_wrappers
    a_url      = "http://google.com"
    a_body     = "A response body"
    a_response = stub(:body => a_body)

    require 'net/http'
    Net::HTTP.stubs(:get_response).returns(a_response)

    # json
    require 'json'
    JSON.expects(:parse).with(a_body)

    get_json(a_url)

    # xml
    require 'faster_xml_simple'
    FasterXmlSimple.expects(:xml_in).with(a_body)

    get_xml(a_url)

    # html
    require 'nokogiri'
    Nokogiri::HTML.expects(:parse).with(a_body)

    get_html(a_url)
  end

  def test_symbolize_keys
    hsh      = {'foo' => 'bar', 'baz' => 'bat' }
    expd_hsh = {:foo  => 'bar', :baz  => 'bat' }

    assert_equal expd_hsh, symbolize_keys(hsh)
  end
end
