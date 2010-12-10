#!/usr/bin/env ruby
require 'rubygems'
require 'mysql'
require 'fastercsv'
require 'geonames'

# To change this template, choose Tools | Templates
# and open the template in the editor.
@connection = Mysql.real_connect("140.254.80.125", "gisman", "gisman$", "gisbank")

res = @connection.query("SELECT * FROM gisbank.locations")
sql = ''
while row = res.fetch_row do
  if(row[1]=='')
    next
  end
  sc = Geonames::ToponymSearchCriteria.new
  sc.q = row[1].chomp.strip
  sc.max_rows = "5"
  rs = Geonames::WebService.search(sc).toponyms
  rs.each do |gn|
    if gn.country_name == row[1].chomp.strip
      sql = "UPDATE gisbank.locations l SET latitude = #{gn.latitude} , longitude  =#{gn.longitude} where country = '#{row[1]}'"
      #return [gn.latitude, gn.longitude]
      break
    end

  end
puts sql
 @connection.query(sql)


end
res.free