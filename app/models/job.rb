class Job < ActiveRecord::Base
  belongs_to :user
  has_many :job_file

=begin
  def validate(params)
    errors=""
    if(params[:job][:name]==nil || params[:job][:name]=='')
      errors << "The job needs a name.\n"
    end

  end
=end


 def start()

    begin

      self.status = "running phenGen"
      self.pid = Process.pid
      self.save

      @dir="#{RAILS_ROOT}/tmp/#{self.id}/"
      path_dir=  "#{RAILS_ROOT}/back_end_scripts/"

      `mkdir #{@dir}`
      `cd #{ @dir}`

      poy_out_file=JobFile.where("file_type = 'poy_out' and job_id=#{self.id}")[0]
      File.open(@dir+poy_out_file.name, 'wb') {|f| f.write(poy_out_file.data) }

      tree_file=JobFile.where("file_type = 'tre' and job_id=#{self.id}")[0]
      File.open(@dir+tree_file.name, 'w') {|f|  f.write(tree_file.data ) }

      ia_file=JobFile.where("file_type = 'ia' and job_id=#{self.id}")[0]
      File.open(@dir+'fasta.ia', 'w') {|f|  f.write(ia_file.data ) }

      `cd #{@dir};  tar -zxvf  #{poy_out_file.name} ; `
      #`unzip #{@dir+poy_out_file.name} -d #{@dir}`

     `awk -f #{path_dir}add_arbitrary_weights.awk #{@dir+tree_file.name} > #{@dir}temp_tree.tre `

     #Note from Sam: We are combining parse_xml.rb with the previous script to produce the _parsed.txt directly.
     #`cat #{@dir}temp_tree.tre #{@dir}#{self.name}.poy_output | #{path_dir}add_tree.pl >#{@dir+self.name}_output.xml`

     #`#{ path_dir}parse_noko_xml.rb #{@dir+self.name}_output.xml >#{@dir+self.name}_parsed.txt`

     #`#{ path_dir}parse_xml.rb #{@dir+self.name}_output.xml >#{@dir+self.name}_parsed.txt`
     `cat #{@dir}temp_tree.tre #{@dir}#{self.name}.poy_output | #{path_dir}add_tree.pl >#{@dir+self.name}_parsed.txt`

     #`echo "awk -f #{path_dir}reweight_tree.awk #{@dir+self.name}_parsed.txt #{@dir+self.name}_parsed.txt > #{@dir+self.name}_rwt.txt" >#{@dir}log.txt `
     `awk -f #{path_dir}reweight_tree.awk #{@dir+self.name}_parsed.txt #{@dir+self.name}_parsed.txt > #{@dir+self.name}_rwt.txt`

     `#{path_dir}divisiderum_postparse_totaldown.pl root  #{@dir+self.name}_rwt.txt > #{@dir+self.name}_down.txt`

     #`sort -k3,3n #{@dir+self.name}_down.txt | awk -f #{path_dir}dirty_reweight.awk #{@dir+self.name}_rwt.txt - > #{@dir+self.name}_cum.txt`

     `#{path_dir}apomorphy_andtable_test_statistic_cox.pl #{@dir+self.name}_rwt.txt  #{@dir+self.name}_down.txt > #{@dir+self.name}_stat.txt`
      save_file self.name+"_stat.txt", 'stat'

     `awk '($1 != $2 && ($3+$4) > 3 && $3 > $5 && ($3-$10)*($3-$10)/$10 >=6){print;}' #{@dir+self.name}_stat.txt > #{@dir+self.name}_stat_p0.05.txt`
      save_file self.name+"_stat_p0.05.txt", 'p'

       `awk '($1 != $2 && ($3+$4) > 3 && $3 > $5 && ($3-$10)*($3-$10)/$10 >=19){print;}' #{@dir+self.name}_stat.txt > #{@dir+self.name}_stat_p0.0001.txt`
	     save_file self.name+"_stat_p0.0001.txt", 'p'
       
       `awk '($1 != $2 && ($3+$4) > 3 && $3 > $5 && ($3-$10)*($3-$10)/$10 >=200){print;}' #{@dir+self.name}_stat.txt > #{@dir+self.name}_stat_p0.00001.txt`
       save_file self.name+"_stat_p0.00001.txt", 'p'

      `#{path_dir}transpose.rb #{@dir+self.name}_stat_p0.00001.txt #{@dir}fasta.ia >#{@dir+self.name}_p0.0001_aln_transpose.txt`
      save_file self.name+"_p0.0001_aln_transpose.txt", 'tan'


      #self.standard_output = @results
      self.status = "complete"
    rescue Exception => ex
      self.status = "failed"
      self.error_output = ex.message+ex.backtrace.to_s
    end

    self.save
 end

  def save_file file_name, type
    file_data =  File.open(@dir+file_name).read
    JobFile.new(:job_id =>self.id, :file_type=>type,:name => file_name,  :data => file_data).save
  end

  def get_files
    return JobFile.find_by_sql("SELECT id,job_id,name,file_type,created_at,updated_at FROM phenGen.job_files where job_id = #{job.id}")
  end


end
