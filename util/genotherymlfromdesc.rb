#this script generates an yml from the description of request to the api other than action=query. the description can be obtained at http://es.wikipedia.org/w/api.php

file = File.new("desc", "r")

str = ""
parameters = false
file.each {|line| 
    case line
    when /^\* (.*)=(.*) \*/
        str += "#{$2}:\n"
    when /^Parameters.*/
        parameters = true
    when /^Example.*/
        parameters = false
    when /^  (\w*)\s*- (.*)/
        if parameters
            str += "  - #{$1}\n"
        end
    end
}
puts str
file.close

