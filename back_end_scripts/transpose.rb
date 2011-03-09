#!/usr/bin/env ruby

hash_main = Hash.new

File.open(ARGV[1], 'r') do |file|
   while line = file.gets
     if line[0]=='>'
       @reader =0;
     else
       line.split(//).each{|char|
       @reader = @reader+2;
        hash_main.has_key?(@reader) ? hash_main[@reader] << char : hash_main.store(@reader, char)
       }
     end
   end
 end

File.open(ARGV[0], 'r') do |file|
   while line = file.gets
     puts line
     puts hash_main[line.split(/\t|:/)[1].to_i]
     puts hash_main[line.split(/\t|:/)[3].to_i]
     puts ''
   end
 end
