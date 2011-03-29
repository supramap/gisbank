#!/usr/bin/env ruby
require 'rubygems'
require 'mysql'
require 'geonames'
#require 'fastercsv'
#require 'sqlite'

class DataAccess
  def initialize()
    @database = SQLite::Database.new("db/development.sqlite3")
  end

  def query query_string
    @database.execute(query_string)
  end
end

#@connection = Mysql.real_connect("140.254.80.125", "gisman", "gisman$", "gisbank")
#@db = DataAccess.new
@db= Mysql.real_connect("localhost", "root", "password", "gisbank")


def add_isolate items
  result = @db.query("SELECT id FROM gisbank.isolates where virus_name =\"#{items[12].strip }\"").fetch_row()
  if (result)
    return result[0]
  else
    location_id = add_location items
    host_id     = add_host items
    pathogen_id = add_pathogen items
    @db.query("INSERT INTO gisbank.isolates(date,virus_name,location_id,pathogen_id,Host_id) VALUES('#{  items[10].strip=='' ? 6 :items[10].strip}-#{items[11].strip=='' ? 15 :items[11].strip}-#{items[9].strip}-00:00:00',\"#{items[12].strip}\",'#{ location_id }','#{pathogen_id}','#{host_id}')")
    return @db.query("SELECT @@IDENTITY").fetch_row()[0]
  end
end

def add_protein items
  result = @db.query("SELECT id FROM gisbank.proteins where name = '#{items[4].strip }'").fetch_row()
  if (result)
    return result[0]
  else
    @db.query("INSERT INTO gisbank.proteins(name) VALUES('#{items[4].strip}')")
    output = @db.query("SELECT @@IDENTITY").fetch_row()[0]
    return output;

  end
end

def geo_search(country, region)
  begin
  if(country == region)
    return 0
  end
  result = @db.query("SELECT id FROM gisbank.locations where name = '#{country}/#{region==''?'other':region}'").fetch_row()
  if (result)
    return result[0]
  else
    str         = region +' '+ country
    sc          = Geonames::ToponymSearchCriteria.new
    sc.q        = str.chomp.strip
    sc.max_rows = "3"
    sleep(5)
    rs = Geonames::WebService.search(sc).toponyms
    rs.each do |gn|
      if (gn.country_name == country.chomp.strip)
        if(region=='')
          region = 'other'
        end
        if(country=='')
          country =  region
          region = 'other'
        end
        sql = "INSERT INTO gisbank.locations(country, gen_bank_label,name,latitude,longitude,local) VALUES(\"#{country}\",\"#{country+'/'+region}\",\"#{country+'/'+region}\",#{gn.latitude},#{gn.longitude},\"#{region}\")"
        @db.query(sql)
        return @db.query("select LAST_INSERT_ID()").fetch_row()[0]
      end
    end
    return 0
    puts 'failed: '+ region +' '+ country 
  end

  rescue StandardError => ex

      puts "geo_search error:"+ex
    return 0
    end
end

  def add_blank_local(country, region)
  if(country == region)
    region = 'other'
  end
  result = @db.query("SELECT id FROM gisbank.locations where name = '#{country}/#{region==''?'other':region}'").fetch_row()
  if (result)
    return result[0]
  else

     sql = "INSERT INTO gisbank.locations(country, gen_bank_label,local) VALUES(\"#{country}\",\"#{country+'/'+region}\",\"#{country+'/'+region}\",\"#{region}\")"
    @db.query(sql)
    return @db.query("select LAST_INSERT_ID()").fetch_row()[0]

    end

  end


def add_location items
  country = items[6].strip

  country == "Viet Nam" ? country ="Vietnam" : ''
  country == "USA" ? country ="United States" : ''
  country == "Cote d'Ivoire" ? country ="Ivory Cost" : ''
  country == "Cote dIvoire" ? country ="Ivory Cost" : ''

  if (items[3].strip=="Human")
    region = items[12].split('/')[1].strip
  else
    region = items[12].split('/')[2].strip
  end
     region == "Viet Nam" ?  region ="Vietnam" : ''
     region == "USA" ? region ="united states" : ''
     region == "Cote d'Ivoire" ? region ="Ivory Cost" : ''

  output = geo_search(country, region)

  if(output==0)
    output2 = geo_search(country, '')
    (output2==0) ? (return geo_search('',  region)) : (return add_blank_local(country, region))
  else
    return output
  end
end

def add_host items
  result = @db.query("SELECT id FROM gisbank.hosts where name = '#{items[3].strip }'").fetch_row()
  if (result)
    return result[0]
  else
    @db.query("INSERT INTO gisbank.hosts(name) VALUES('#{items[3].strip}')")
    return @db.query("SELECT @@IDENTITY").fetch_row()[0]
  end
end

def add_pathogen items
  result = @db.query("SELECT id FROM gisbank.pathogens where name = '#{items[5].strip }'").fetch_row()
  if (result)
    return result[0]
  else
    @db.query("INSERT INTO gisbank.pathogens(name) VALUES('#{items[5].strip}')")
    return @db.query("SELECT @@IDENTITY").fetch_row()[0]
  end
end

#ARGV[0] = 'H5N1(3-1-2011).fa'
fails=0
file    = File.open(ARGV[0]).read.gsub(/\r|\n/, '').split('>').each { |seq|
begin
  items = seq.split('|')
  if (items.count<10)
    next
  end
  result = @db.query("SELECT id FROM gisbank.sequences where accession = '#{items[0].strip }'").fetch_row()
  if (result)
    puts "accession : #{items[0].strip} is already in the database"
  else
    protein_id = add_protein(items)
    isolate_id = add_isolate(items)
    @db.query("INSERT INTO gisbank.sequences(Isolate_id,protein_id,accession,data) VALUES('#{isolate_id }','#{ protein_id}','#{items[0].strip}','#{items[13].gsub(/ |\r|\n/, '')}')");
  end
  rescue StandardError => ex
  puts ex
  fails = fails+1
  puts "failed #{fails} number of times "
  #next
end
}

