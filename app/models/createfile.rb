require 'fileutils'
require 'date'

class Createfile

  def self.file_prep(user_id, project_id, query_id)
    folder = 'public/files/'+user_id.to_s+'/'+project_id.to_s+'/'+query_id.to_s
    if (File.file?(folder+"/seq.fas"))
      FileUtils.rm_r(folder)
    end
    FileUtils.mkdir_p(folder)
    return folder
  end

  def self.make_fasta(folder, arr)
    arr.each { |seq| fasta_block(folder, seq[:sequence_id], seq[:genbank_acc_id], seq[:data]) }
  end

  def self.make_csv(folder, arr)
    arr.each do |seq|
      csv_block(folder,seq[:sequence_id],seq[:genbank_acc_id],seq[:latitude].to_s,seq[:longitude].to_s,seq[:collect_date].to_s)
    end
  end

  def self.make_strain(folder, arr)
    arr.each do |seq|
      strain_block(folder,seq[:sequence_id],seq[:genbank_acc_id],seq[:sequence_type],seq[:name],seq[:host],seq[:location],seq[:h1n1_swine_set])
    end
  end

  def self.print_stuff(stuff)
    return stuff
  end

  def self.format_date(dt)
    values = Time.parse(dt)
    d = Time.local(*values)
    return d.strftime("%Y-%m-%d")
  end

  private

  # sample input for fasta
  # arr = [{:sequence_id => 'EPI171711' ,:data => 'agctcacttctcg'} ,{:sequence_id => 'EPI171706', :data => 'ttttggagaggccgcgaga'}, {:sequence_id => 'EPItest' ,:data =>'aattgggggg'}]
  def self.fasta_block(path, seqid, genid, data)
    File.open(path + "/seq.fas","a") do |the_file|
      if (seqid != nil && data != nil)
        the_file.puts '>' + seqid + "\n" + data + "\n"
      end
      if (genid != nil && data != nil)
        the_file.puts '>' + genid + "\n" + data + "\n"
      end
    end
  end

  # sample input for csv
  # arr = [{:sequence_id => 'EPI78777', :lat => '34.23', :long =>'-102.22', :date => '2009-05-30'},{:sequence_id => 'EPI88888', :lat =>'0', :long =>'21.34', :date =>'1980-01-13'},{:sequence_id =>'EPI900991',:lat =>'12.12',:long =>'-45.76',:date =>'2001-09-11'}]
  def self.csv_block(path, sequence_id, gb_acc_id, lat, long, date)
    File.open(path + "/georef.csv","a") do |the_file|
      if (sequence_id != nil && lat != nil && long != nil && date != nil)
        the_file.puts sequence_id + ',' + lat + ',' + long + ',' + format_date(date) + "\n"
      end
      if (sequence_id == nil && lat != nil && long != nil && date != nil)
        the_file.puts gb_acc_id + ',' + lat + ',' + long + ',' + format_date(date) + "\n"
      end
    end
  end

  def self.strain_block(path, sequence_id, gb_acc_id, type, name, host, location, swl)
    File.open(path + "/metadata.csv","a") do |the_file|
      if (sequence_id != nil && type != nil && name != nil && host != nil && location != nil && swl != nil)
        the_file.puts sequence_id + ',' + type + ',' + name + ',' + host + ',' + location + ',' + swl +"\n"
      end
      if (sequence_id == nil && type != nil && name != nil && host != nil && location != nil && swl != nil)
        the_file.puts gb_acc_id + ',' + type + ',' + name + ',' + host + ',' + location + ',' + swl + "\n"
      end
    end
  end

end
