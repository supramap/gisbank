#!/usr/bin/env ruby
require 'rubygems'
require 'mysql'
require 'fastercsv'

#def remove_end_text_till_space(input)
#  removed = 'a'
#  begin
#    removed = input.slice!( input.length-1)
#  end while !(removed == ' ' || removed == 32 )
#  return input
#end

def  get_ncbi_id(header_line)
   ary = header_line.strip.split(' ')
   ncbi_id = ary[1].strip
   count = 1
   while !( 40 <=  ary[count+1][0]  && ary[count+1][0]   <= 57)
    count = count +1
    ncbi_id = ncbi_id+" "+ary[count].strip
   end
  return ncbi_id
  
  #    ary = header_line.strip.split(' ')
#  ncbi_id = ary[1].strip
#   count = 1
#   while (count < ary.length-4)
#    count = count +1
#    ncbi_id = ncbi_id+" "+ary[count].strip
#    puts ncbi_id
#    puts count
#   end
#  return ncbi_id

#
#   ary = header_line.strip.split(' ')
#   ncbi_id = ary[1].strip
#   count = 1
#   while !(40 <=  ncbi_id[ncbi_id.length-1] && ncbi_id[ncbi_id.length-1]  <= 57)
#    count = count +1
#    ncbi_id = ncbi_id+" "+ary[count].strip
#   end
#  return ncbi_id
end

@connection = Mysql.real_connect("140.254.80.125", "gisman", "gisman$", "gisbank")
@count=0
@error_count=0
puts "established database connection"

begin
  sequences_segment = ''
  header_line = ''
  protien = ''
  sql =''
  line_count =0;
  @error_file = File.open("error.txt", 'w')
  file = File.open("../raw_data/FASTA.fa")do |infile|
    while (line = infile.gets)
      line_count= line_count +1;
      if(line[0]==62)
       
        if(header_line.strip != '')
          begin
           

            ncbi_id =get_ncbi_id(header_line)
      
            sql = "SELECT  ncbi_isolate_id FROM gisbank.ncbi_isolate where ncbi_id= \"#{ ncbi_id}\""
            ncbi_isolate_id = @connection.query(sql).fetch_row()[0]

            sql = "INSERT INTO gisbank.ncbi_sequences(ncbi_isolate_id,name,protein,data )
            VALUES(\"#{ncbi_isolate_id}\",\"#{header_line}\",\"#{protien}\",\"#{sequences_segment}\")"
            @connection.query(sql)
            
          rescue => err
            @error_file.puts "Failed while reading line #{ line_count}"
            @error_file.puts "Error is #{err}"
            @error_file.puts sql
            @error_file.puts "\n"
            @error_file.puts ncbi_id
            @error_file.puts ncbi_isolate_id
            @error_file.puts header_line
            @error_file.puts protien
            @error_file.puts sequences_segment
            @error_count=@error_count+1
            @error_file.puts @error_count
            @error_file.puts "\n\n\n ******end*********\n\n\n"

          end
          @count = @count+1
          puts "added #{header_line} for a total of #{@count}"
          #puts header_line
          #puts protien
          #puts "----------------"
        end
        sequences_segment =''
        #header_line =  line[1,line.length-1]
        #protien = line[line.length-3, line.length-1]
        header_line= line.strip
        protien = line.strip.split(" ")[line.strip.split(" ").length-1].delete("(").delete(")")
        
        #protien = line.strip.split(' ')[line.split(' ').length-1]
        #header_line =  line.strip[1,line.strip.length-(protien.length+1)]
      else
        sequences_segment = sequences_segment + line;
      end
    end
  end

#  rescue => err
#            @error_file.puts "Failed while reading line #{ line_count}"
#            @error_file.puts "Error is #{err}"
#            @error_file.puts sql
#            @error_file.puts "\n"
#            #@error_file.puts ncbi_id
#            #@error_file.puts ncbi_isolate_id
#            @error_file.puts header_line
#            @error_file.puts protien
#            @error_file.puts sequences_segment
#            @error_file.puts "\n\n\n ******end*********\n\n\n"
end