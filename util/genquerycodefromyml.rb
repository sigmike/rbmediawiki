#This script generates code from a yml description of the api (requests to the method action=query, other actions have another generator). The yml description can be obtained from the mediawikidocumentation using genqueryymlfromdesc
require 'yaml'

Apiconf = YAML::load(File.open("queries.yml"))

str =""
Apiconf.each {|root|
    root.each {|method|
        if Apiconf[method]
            method =~ /(.*)=(.*)/
            str += "def query_#{$1}_#{$2}(titles = nil, "
            Apiconf[method].each {|param| 
                str += "#{param} = nil, "
            }
            str = str+ "pageids = nil, revids = nil, redirects = nil, indexpageids = nil, export = nil, exportnowrap = nil, post_me = nil)\n\n"
            Apiconf[method].each {|param| 
                str += "    post_me = add_post('#{param}', #{param}, post_me)\n"
            }
            str += "    post_me = add_post('#{$1}', '#{$2}', post_me)\n"
            str += "    post_me = query(post_me, titles, pageids, revids, redirects, indexpageids, export, exportnowrap)\n"
            str += "    post_me = format(post_me, 'xml')\n"
            str += "    result = make_request(post_me)\n"
            str += "    return result\n"
            str += "end\n\n"
        end
    }
}

puts str
