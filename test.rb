#!/usr/bin/ruby

require 'emc/xmlapi'

EMC::XMLAPI.start('172.30.49.9', 'nasadmin', :password => 'nasadmin') do |session|

end
