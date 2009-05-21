#!/usr/bin/sh

ruby genqueryymlfromdesc.rb > queries.yml 
ruby genotherymlfromdesc.rb > other.yml
ruby genquerycodefromyml.rb > queries.rb
ruby genothercodefromyml.rb > other.rb
