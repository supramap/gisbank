#!/usr/bin/env ruby
require 'rubygems'
require 'mysql'
require 'fastercsv' 


@connection = Mysql.real_connect("140.254.80.125", "gisman", "gisman$", "gisbank")
@last_virus_name=""
@count=0


 @connection.query("Truncate Table ncbi_isolate")
  @connection.query("truncate table gisbank.ncbi_sequences")
FasterCSV.foreach("flu.txt") do |row|

  if(row[7] != @last_virus_name )
  @last_virus_name = row[7]
  virus_tag = row[7].split('(')[1].split(')')[0]

  date = row[6]
  if(date.length==4)
    date = date+"-00-00:00:00:00"
  end
   
     @connection.query("INSERT INTO ncbi_isolate (ncbi_id, host, subtype, country, date,virus_name,age,gender, mutation, ncbi_name)
                VALUES(\"#{row[0]}\",\"#{row[2]}\", \"#{row[4]}\", \"#{row[5]}\", \"#{date}\", \"#{row[7]}\", \"#{row[8]}\", \"#{row[9]}\", \"#{row[10]}\", \"#{virus_tag}\") ")
                
    id = @connection.query("select LAST_INSERT_ID()").fetch_row() [0]
      puts id
      @count = @count+1
   puts("#{@last_virus_name} inserted #{@count}")
  end
end

