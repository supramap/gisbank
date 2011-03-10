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
               VALUES(\"#{row[0]}\",\"#{row[2]}\", \"#{row[4]}\", \"#{row[5]}\", \"#{date}\", \"#{row[7]}\", \"#{row[8]}\", \"#{row[9]}\", \"#{row[10]}\", \"#{virus_tag}\")")

    @id = @connection.query("select LAST_INSERT_ID()").fetch_row() [0]

    @count = @count+1
    puts("#{@count} isolates inserted Name:#{@last_virus_name}")
  end
  sql = "INSERT INTO gisbank.ncbi_sequences(ncbi_isolate_id, accession)
           VALUES(\"#{@id}\",\"#{row[0]}\")"
  @connection.query(sql)
end
@count=0
header_line=''  
sequences_segment = ''
protien = ''
ncbi_id =''

file = File.open("FASTA.fa")do |infile|
  while (line = infile.gets)
    #puts line
    if(line[0]==62 or line[0]=='>')
      if(header_line.strip != '')
     
         
          sql = "UPDATE gisbank.ncbi_sequences SET
          name =\"#{header_line}\",
          protein = \"#{protien}\",
          data = \"#{sequences_segment}\"
          where accession = \"#{ ncbi_id}\""

          #puts(sql)

          @connection.query(sql)

          @count= @count+1
          puts("#{@count} sequences inserted Name:#{ncbi_id}")
        end
        
         header_line= line.strip
        sequences_segment =''
        protien = line.strip.split(" ")[line.strip.split(" ").length-1].delete("(").delete(")")
        ncbi_id =header_line.split(' ')[0].split(':')[1]
      
    else
      sequences_segment = sequences_segment + line;
    end
  end
end

