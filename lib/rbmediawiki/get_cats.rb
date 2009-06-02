require './rbmediawiki'
require './rbmediawiki/page'

site = Api.new(nil, nil, 'chabacano', 'http://es.wikipedia.org', 'http://es.wikipedia.org/w/api.php')
cat = Category.new(ARGV[0], site)
cl = cat.get_members()

puts cl

