require './rbmediawiki'

site = Api.new(nil, nil, 'chabacano', 'http://es.wikipedia.org', 'http://es.wikipedia.org/w/api.php')
page = Page.new(ARGV[0],site)
cl = page.get_categories()
puts cl ? cl.size : 0

