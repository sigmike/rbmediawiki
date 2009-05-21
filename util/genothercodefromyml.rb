#This script generates code from a yml description of the api (requests *other* than action=query, that ahs its own generator). The yml description can be obtained from the mediawikidocumentation using genotherymlfromdesc
require 'yaml'

Apiconf = YAML::load(File.open("other.yml"))

str =""
Apiconf.each {|root|
    root.each {|method|
        if Apiconf[method]
            str += "def #{method}("
            Apiconf[method].each {|param| 
                str += "#{param} = nil, "
            }
            str = str+ "post_me = nil)\n\n"
            Apiconf[method].each {|param| 
                str += "    post_me = add_post('#{param}', #{param}, post_me)\n"
            }
            str += "    post_me = add_post('action', '#{method}', post_me)\n"
            str += "    post_me = format(post_me, 'xml')\n"
            str += "    result = make_request(post_me)\n"
            str += "    return result\n"
            str += "end\n\n"
        end
    }
}

puts str
