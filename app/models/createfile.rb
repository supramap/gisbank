require 'fileutils'

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
    arr.each { |gis| fasta_block(folder,gis[:sequence_id],gis[:data]) }
  end

  def self.make_csv(folder, arr)
    arr.each do |seq|
      iso = seq.isolate
      csv_block(folder,seq[:sequence_id],iso[:latitude].to_s,iso[:longitude].to_s,iso[:collect_date].to_s)
    end
  end

  private

  # sample input for fasta
  # arr = [{:sequence_id => 'EPI171711' ,:data => 'agctcacttctcg'} ,{:sequence_id => 'EPI171706', :data => 'ttttggagaggccgcgaga'}, {:sequence_id => 'EPItest' ,:data =>'aattgggggg'}]
  def self.fasta_block(path,sequence_id,data)
    File.open(path + "/seq.fas","a") do |the_file|
      if (sequence_id != nil && data != nil)
        the_file.puts '>' + sequence_id + "\n" + data + "\n"
      end
    end
  end

  # sample input for csv
  # arr = [{:sequence_id => 'EPI78777', :lat => '34.23', :long =>'-102.22', :date => '2009-05-30'},{:sequence_id => 'EPI88888', :lat =>'0', :long =>'21.34', :date =>'1980-01-13'},{:sequence_id =>'EPI900991',:lat =>'12.12',:long =>'-45.76',:date =>'2001-09-11'}]
  def self.csv_block(path,sequence_id,lat,long,date)
    File.open(path + "/georef.csv","a") do |the_file|
      if (sequence_id != nil && lat != nil && long != nil && date != nil)
        the_file.puts sequence_id + ',' + lat + ',' + long + ',' + date + "\n"
      end
    end
  end
  
end
