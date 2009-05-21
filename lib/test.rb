require 'rbmediawiki'

#mysite = Api.new(nil, nil, 'chabacano', 'http://127.0.0.1/wiki', 'http://127.0.0.1/wiki/api.php')
mysite = Api.new(nil, nil, 'chabbot', 'http://es.wikipedia.org', 'http://es.wikipedia.org/w/api.php')

myuser = User.new("Títere", mysite)
mypage = Page.new("User talk:Títere", mysite)
mygen  = Misc_generator.new(mysite)

roads = Array.new

begin
    gen = mygen.history("Félix Houphouët-Boigny")
    while gen.next?
      rev = gen.next
      puts rev
      sleep(1)
    end

rescue RbmediawikiError => error
    puts error

rescue NoPage => error
    puts error
end
