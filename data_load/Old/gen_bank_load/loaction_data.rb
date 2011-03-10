#!/usr/bin/env ruby
require 'rubygems'
require 'mysql'
require 'fastercsv'
require 'geonames'

@connection = Mysql.real_connect("140.254.80.125", "gisman", "gisman$", "gisbank")

def find_by_string(id, local, country)

  if(local == country)
    return true
  end

  if(/^[\d]+(\.[\d]+){0,1}$/ === local)
    return false
  end

  sql = "SELECT id FROM gisbank.locations where name ='#{country+'/'+local }'"
  res = @connection.query(sql).fetch_row
  if(res and res[0])
    sql = "UPDATE gisbank.ncbi_isolate set location_id = #{res[0]} where ncbi_isolate_id=#{id}"
    @connection.query(sql)
    return true
  end

  str = local+' '+ country
  sc = Geonames::ToponymSearchCriteria.new
  sc.q = str.chomp.strip
  sc.max_rows = "3"
  sleep(3)
  rs = Geonames::WebService.search(sc).toponyms
  rs.each do |gn|
    if gn.country_name == country.chomp.strip
      sql = "INSERT INTO gisbank.locations(country, gen_bank_label,name,latitude,longitude,local) VALUES(\"#{country}\",\"#{country+'/'+local}\",\"#{country+'/'+local}\",#{gn.latitude},#{gn.longitude},\"#{local}\")"
      @connection.query(sql)
      puts "added #{country+'\\'+local} at #{gn.latitude},#{gn.longitude} for isolate #{id}"
      local_id = @connection.query("select LAST_INSERT_ID()").fetch_row() [0]
      sql = "UPDATE gisbank.ncbi_isolate set location_id = #{local_id} where ncbi_isolate_id=#{id}"
      @connection.query(sql)
      return true
      return [gn.latitude, gn.longitude]
    end
  end
  return false
end

@connection = Mysql.real_connect("140.254.80.125", "gisman", "gisman$", "gisbank")

@connection.query("truncate table gisbank.locations")

@connection.query("insert into gisbank.locations(country, gen_bank_label,name,local )
select country, CONCAT(country,'/Other') as gen_bank_label ,CONCAT(country,'/Other') as name,\"Other\" from gisbank.ncbi_isolate group by country")

@connection.query("
UPDATE ncbi_isolate, locations 
SET ncbi_isolate.location_id= locations.id
WHERE ncbi_isolate.country= locations.country")

res = @connection.query("SELECT * FROM gisbank.locations")
sql = ''
while row = res.fetch_row do
  if(row[1]=='')
    next
  end
  #puts  row[1].chomp.strip
  sc = Geonames::ToponymSearchCriteria.new
  sc.q = row[1].chomp.strip
  sc.max_rows = "1"
  sleep(3)
  rs = Geonames::WebService.search(sc).toponyms
  rs.each do |gn|
    #if gn.country_name == row[1].chomp.strip
      sql = "UPDATE gisbank.locations l SET latitude = #{gn.latitude} , longitude  =#{gn.longitude}, country='#{gn.country_name}', name='#{gn.country_name}/Other' where country = '#{row[1]}'"
      @connection.query(sql)
      puts "added #{row[1]+'/Other'} at #{gn.latitude},#{gn.longitude} "
      #break
    #end
  end
end

res = @connection.query("SELECT * FROM gisbank.ncbi_isolate")
while row = res.fetch_row do

  begin
    if(row[3]=="Human")
    	find_by_string(row[0], row[7].split('/')[1],  row[5])
     else
       find_by_string(row[0], row[7].split('/')[2],  row[5])
    end
  rescue => err
    puts "error at #{row[6]},#{row[4]},#{row[0]}"
    puts err
  end
end
