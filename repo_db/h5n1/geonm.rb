#!/usr/bin/env ruby
require 'rubygems'
require 'geonames'
require 'csv'

NON_MATCH_MAP = Set.new

def generate_geo_file (in_file, out_file)
  csv_rows = parse_csv_file( in_file )
  puts "Parsing csv file... done"
  puts "Searching for georeferences (this could take a while ~ 1 sec/row):"  
  cached_geo_map = {}

  csv_rows.each_with_index do |row, i|
    display_progress(i + 1, csv_rows.length)

    lat, long = 0
    city, state, country = row[-3], row[-2], row[-1]
    
    search_str = cleanup_and_join_search_str(city,state,country)
    
    # continue if empty
    next if search_str.nil? or search_str.empty?
    
    # geonames ws calls are expensive, cache results
    if cached_geo_map.member?( search_str )
      lat, long = cached_geo_map[search_str]
    else
      lat, long = find_by_string(search_str, country)
      cached_geo_map[search_str] = [lat, long]
    end

    # adds lat and long to end of row
    row << lat
    row << long
  end
  
  write_non_match_search_strs
  
  out_file = (out_file.nil? or out_file.empty?) ? in_file.dup << ".out" : out_file
  puts "\nWriting to output file: #{out_file}..."
  output_to_file( csv_rows, out_file ) 
  puts "Finished. Read and geo-referenced #{csv_rows.length} rows."
  exit(0)
end

def display_progress(count, length)
  print "\r\e[K"
  print "#{count}/#{length} #{(count/length.to_f * 100).round}%"
  STDOUT.flush
end

def write_non_match_search_strs
  puts "\n\nCouldn't find georefereces for:" unless NON_MATCH_MAP.empty?
  NON_MATCH_MAP.each do |el|
    puts "#{el}"
  end
end

def output_to_file( rows, out_file )
  File.open(out_file, 'w') do |f|
    rows.each do |row|
      f.write( "#{row.join(',')}\n" )
    end
  end
end

def cleanup_and_join_search_str(city, state, country)
  [city, state, country].find_all {|it| !(it.nil? or it.strip.chomp.empty?)}.join(" ")
end

# Calls geonames web service.  Checks the result to make
# sure it's in the right country to avoid returning London, Montana
# for London, England
#
# Note: this call is expensive.
def find_by_string(str, country_str)
  sc = Geonames::ToponymSearchCriteria.new
  sc.q = str.chomp.strip
  sc.max_rows = "3"
  rs = Geonames::WebService.search(sc).toponyms
  rs.each do |gn|
    if gn.country_name = country_str.chomp.strip
      return [gn.latitude, gn.longitude]
    end
  end
  
  # if we get here, there was no match for the search string - record it
  NON_MATCH_MAP.add(str) unless NON_MATCH_MAP.member? str
  
end

def parse_csv_file(file)
  csv_rows = CSV.read(file)
  abort("The csv file was empty") if csv_rows.nil? or csv_rows.length == 0
  
  # checks for header and skips if present
  csv_rows.shift if header? csv_rows[0][-3], csv_rows[0][-2], csv_rows[0][-1]
  csv_rows
end

# checks if a csv row is a header or valid data.  There's now way to tell for sure,
# but the code assumes that the user will put "state", or "country", or "region", in
# one of the columns.
def header?(state, region, country)
  (state =~ /state/xi) or (region =~ /region/xi) or (country =~ /country/xi)
end

def help_message
  puts """This script adds georeferences to a csv file
that contains the following columns (header is optional):

x (optional), y (optional), ..., region/state/province, region, country

The script allows n number of columns, as long
as the state, region and country are the n-2, n-1, and nth
columns, respectively.

USAGE:
 geonm.rb [--help] [-h] path_to_input_file [path_to_output_file]

If no path to the output file is given, then it will default to
path_to_input_file.out.  The format of the output file will be:

x (optional), y (optional), ..., city, region/state/province, country, lat, long
"""
end

if $0 == __FILE__
  if ARGV[0] == "--help" or ARGV[0] == "-h"
    help_message
    exit(0)
  else
    generate_geo_file(ARGV[0], ARGV[1])
  end
end


