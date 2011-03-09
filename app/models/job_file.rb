class JobFile < ActiveRecord::Base
  belongs_to :job

  def write dir
    File.open(dir+name, 'w') {|f| f.write(data) }

  end

  def self.save_file(id,dir, file_name, type)
    file_data =  File.open(dir+file_name).read
    JobFile.new(:job_id =>id, :file_type=>type,:name => file_name,  :data => file_data).save
  end

   def self.get_files job_id
    return JobFile.find_by_sql("SELECT id,job_id,name,file_type,created_at,updated_at FROM phenGen.job_files where job_id = #{job_id}")
  end

end