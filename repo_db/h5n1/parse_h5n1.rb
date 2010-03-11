require 'csv'
require 'h5n1_gisaid_db'


parse_csv = lambda {|path_to_csv, fname|
  puts "Parsing #{path_to_csv}....      "
  csv_rows = CSV.read(path_to_csv)
  # gets rid of header column
  count = 0
  csv_rows.shift
  csv_rows.each do |row| 
    save_isolate_row(row, fname.split('.')[0].upcase)
    count += 1
  end
  
  puts "#{count} rows saved"
}

parse_fasta = lambda {|path_to_fasta, fname|
  print "Parsing #{path_to_fasta}....    "
  seq = nil
  data = ""
  File.open(path_to_fasta, 'r') do |f|
    f.each do |line|
      if line[0] == 62 # ascii for '>'
        # save previous sequence
        unless seq.nil?
          seq.data = data
          #puts data
          #puts "Saving seq: #{seq.sequence_id}, #{seq.isolate_id}, #{seq.accession_id}, #{seq.data.length}"
          seq.save!
        end
        
        # start parsing new sequence
        parts = line.chomp.split('|')
        first_part = parts[0].strip[1,parts[0].length] # strips off leading '>'
        seq = (parts[0].strip == ">gi") ? Sequence.first(:conditions => ["genbank_acc_id = ?", parts[3].split('.')[0].strip]) : Sequence.first(:conditions => ["sequence_id = ?", first_part])
        data = ""        
        if seq.nil?
          puts "No sequence for #{parts}"
        end

      else
        data << line.chomp
      end
    end
    
    seq.data = data
    #puts "Saving last seq: #{seq.sequence_id}, #{seq.isolate_id}, #{seq.accession_id}, #{seq.data.length}"
    # saves last sequence
    seq.save! unless seq.nil?
  end
  puts "OK"
}

#
# takes a row from the csv file and saves the isolate to the db
#
def save_isolate_row(row, seq_type)
  iso = Isolate.new
  count = 0
  Isolate.properties.each do |prop|
    if prop.name == :id or prop.name == :created_at
      next
    end
    
    if prop.name == :collect_date
      iso.attribute_set(prop.name, fix_date(row[count]))
      count = count + 1
      next
    end
    iso.attribute_set(prop.name, row[count]) 
    count = (count == 0) ? 3 : count + 1 # skip some of the columns
  end
  
  begin

    iso.save!
    seq = create_sequence(iso.sequence_ids, row[1], row[2])
    seq.sequence_type = seq_type unless seq.sequence_type
    seq.isolate_id = iso.id
    seq.save!
  rescue MysqlError => me
    puts "Saving seq after iso already present..."
    seq = create_sequence(iso.sequence_ids, row[1], row[2])
    seq.sequence_type = seq_type unless seq.sequence_type    
    seq.isolate_id = Isolate.first(:conditions => ["isolate_id = ? OR taxid = ?", iso.isolate_id, iso.taxid]).id
    begin
      seq.save!
    rescue MysqlError => me
      
    end
  end
  
end

def create_sequence(ids, acc, epi_id)
  
  unless epi_id
    seq = Sequence.new
    seq.genbank_acc_id = acc
    return seq
  end
  
  seq_parts = ids.split('/')
  seq_parts.each do |part|
    type, id = part.split(':')
    if id.strip == epi_id
      seq = Sequence.new
      seq.sequence_id = id.strip
      seq.sequence_type = type.strip
      seq.genbank_acc_id = acc
      return seq
    end
  end
  puts "It's bad if we get here..."
end



def parse_files_in_dir(path_to_dir, parser_fun)
  dir = Dir.new(path_to_dir)
  dir.each do |fname|
    parser_fun.call("#{path_to_dir}/#{fname}", fname) if fname != "." and fname != ".."
  end
  #parser_fun.call("/Users/ttreseder/code/work/gisaid_parser/combined/fasta/ha.fasta", "ha.fasta")
end

def fix_date(date_str)
    y, m, d = date_str.split('-')
    year = get_correct_year(y.to_i)
    month = (m.to_i == 0) ? 1 : m.to_i
    day = (d.to_i == 0) ? 1 : d.to_i
    
    DateTime.new(year,month,day)
end

def get_correct_year(bad_year)
  return bad_year + 2000 if bad_year < 10
  return bad_year + 1900 if bad_year < 100
  return bad_year
end

def check_dates
  rows = Isolate.all
  rows.each do |row|
    row.collect_date_2 = fix_date(row.collect_date)
    row.save!
  end
end

def add_type_column_to_sequences
  isos = Isolate.all
  isos.each do |iso|
    parse_sequence_ids_and_save(iso.id,iso.sequence_ids)
  end
end

def parse_sequence_ids_and_save(iid, line)
  type_and_ids = line.split('/')
  type_and_ids.each do |str|
    s_type, id = str.split(':')
    seq = Sequence.first(:sequence_id => id.strip)
    seq.sequence_type = s_type.strip
    seq.isolate_id = iid
    puts "Saving seq #{seq.sequence_id} with isolate_id = #{iid} and type as #{seq.sequence_type}"
    seq.save!
  end
  
end

parse_files_in_dir("/Users/manirupa/Work/gisbank/scripts/h5n1data/fasta", parse_fasta)

#check_dates
#add_type_column_to_sequences
#parse_files_in_dir("/Users/ttreseder/code/work/gisaid_parser/combined/fasta", parse_fasta)