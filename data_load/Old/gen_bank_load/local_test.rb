#!/usr/bin/env ruby
require 'rubygems'
require 'mysql'
#require 'fastercsv'
require 'geonames'

def printinfo(name)
	puts "\n\nstart: #{name}"
	sc = Geonames::ToponymSearchCriteria.new
	  sc.q = name
	  sc.max_rows = "3"
	  sleep(3)
	  rs = Geonames::WebService.search(sc).toponyms
	  rs.each do |gn|
		puts gn.latitude
		puts gn.longitude
		puts gn
	end
end

printinfo("USA")
printinfo("Cote dIvoire")
printinfo("Gaza Strip")
printinfo("Shantou Shantou")
