#!/usr/bin/env ruby
require 'rubygems'
require 'mysql'
require 'fastercsv' 

@connection = Mysql.real_connect("140.254.80.125", "gisman", "gisman$", "gisbank")
@count=0

@connection.query("Truncate Table gisbank.isolates_gisaid")
@connection.query("Truncate Table gisbank.sequences_gisaid")

FasterCSV.foreach("gisaid_epiflu_isolates.csv") do |row|

    date = row[14]
    if(date.length==4)
      date = date+"-00-00:00:00:00"
    end
    
    @connection.query("INSERT INTO isolates_gisaid (gisaid_id, host, subtype, location, date,virus_name)
               VALUES(\"#{row[0]}\",\"#{row[7]}\", \"#{row[3].split('/')[1].strip}\", \"#{row[6]}\", \"#{date}\", \"#{row[2]}\")")

    @id = @connection.query("select LAST_INSERT_ID()").fetch_row() [0]

    @count = @count+1
    puts("#{@count} isolates inserted Name:#{row[2]}")

  row[1].split('/').each { |name|

    sql = "INSERT INTO sequences_gisaid(Isolates_gisaid_id, protein, accession)
           VALUES(\"#{@id}\",\"#{name.split(':')[0].strip}\",\"#{name.split(':')[1].strip}\")"
    @connection.query(sql)

  }

end
@count=0
header_line=''  
sequences_segment = ''
protien = ''
accession =''

file = File.open("gisaid_epiflu_sequence.fasta")do |infile|
  while (line = infile.gets)
    #puts line
    if(line[0]==62 or line[0]=='>')
      if(header_line.strip != '')
     
          sql = "UPDATE sequences_gisaid SET
          name =\"#{header_line}\",
         
          data = \"#{sequences_segment}\"
          where accession = \"#{ accession}\""

          #puts(sql)

          @connection.query(sql)

          @count= @count+1
          puts("#{@count} sequences inserted Name:#{accession}")
        end
        
         header_line= line.strip
        sequences_segment =''
   
        accession =header_line.split('|')[1].strip
      
    else
      sequences_segment = sequences_segment + line;
    end
  end
end

