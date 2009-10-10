$: << File.join(File.dirname(__FILE__), "..", "lib")

require "test/unit"
require "rbmediawiki"
require 'pp'

class TestRbmediawiki < Test::Unit::TestCase
  def test_retrieve_piglobot_contributions
    site = Api.new(nil, nil, nil, 'http://fr.wikipedia.org', 'http://fr.wikipedia.org/w/api.php')
    piglobot = User.new("Piglobot", site)
    assert piglobot.get_usercontribs(5)
  end
end
