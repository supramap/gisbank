class PhenGenController < ApplicationController
  before_filter :require_user, :only => [:list, :new, :create]

  def home
  end
  
  def list
    @jobs = Job.where("user_id = #{current_user.id}")
  end

  def new
    @job = Job.new
  end
  
  def create
    @job = Job.new(:name => params[:job][:name], :status => "running",:user_id => current_user.id, :pid => Process.pid )

    #@job = Job.new
    #@job.name = params[:job]
    #@job.status = "running"
    #@job.user_id = current_user.id
    #@job.pid = Process.pid
    @job.save
    #@job.uploaded_file = params[:job][:uploaded_file]
    file =  File.open(params[:job][:fasta_file].tempfile.path).read
    @fasta_file = InputFile.new(:job_id =>@job.id, :type=>'fas', :name => params[:job][:fasta_file].original_filename,  :data => file)
    file =  File.open(params[:job][:tree_file].tempfile.path).read
    @tree_file = InputFile.new(:job_id =>@job.id, :type=>'tre',:name => params[:job][:tree_file].original_filename,  :data => file)
    #@input_file = InputFile.new(:job_id =>@job.id, :name => params[:job][:uploaded_file].original_filename,  :data => File.open(params[:job][:uploaded_file].tempfile.path))
    #@input_file = InputFile.new(:job_id =>@job.id, :name => params[:job][:uploaded_file].original_filename,  :data => params[:job][:uploaded_file].read)
    @fasta_file.save
    @tree_file.save
    fork do
     
     # `back_end_scripts/parse_xml.rb tmp/1/1_output.xml > tmp/1/rawRails_parsed.txt`
     #  `/home/jacob/phenGen/back_end_scripts/parse_xml.rb /home/jacob/phenGen/tmp/1/1_output.xml > /home/jacob/phenGen/tmp/1/rawRails2_parsed.txt`

      dir="#{RAILS_ROOT}/tmp/#{@job.id}/"
      path_dir=  "#{RAILS_ROOT}/back_end_scripts/"
      `mkdir #{RAILS_ROOT}/tmp/#{@job.id}`
      
      
      #`echo '#{RAILS_ROOT}/back_end_scripts/parse_xml.rb #{dir+@job.name}_output.xml >#{dir+@job.name}_parsed.txt' >>#{dir}log.txt`


      File.open(dir+@fasta_file.name, 'w') {|f| f.write(@fasta_file.data) }
      File.open(dir+@tree_file.name, 'w') {|f|  f.write(@tree_file.data ) }
      `cat #{dir+@tree_file.name} #{dir+@fasta_file.name} | #{RAILS_ROOT}/back_end_scripts/add_tree.pl >#{dir+@job.name}_output.xml`

      @command_string = "#{RAILS_ROOT}/back_end_scripts/parse_xml.rb #{dir+@job.name}_output.xml >#{dir+@job.name}_parsed.txt"
       `echo '#{@command_string}' >>#{dir}log.txt`
       `echo $PATH >>#{dir}log.txt`
       `whereis ruby >>#{dir}log.txt`
       `ruby -v >>#{dir}log.txt`
      `#{@command_string}`
      #`#{RAILS_ROOT}/back_end_scripts/parse_xml.rb #{dir+@job.name}_output.xml >#{dir+@job.name}_parsed.txt`

      `cp -f #{path_dir}sample_parsed.txt #{dir+@job.name}_parsed.txt`
    `awk -f #{path_dir}reweight_tree.awk #{dir+@job.name}_parsed.txt #{dir+@job.name}_parsed.txt > #{dir+@job.name}_rwt.txt`
    `#{path_dir}divisiderum_postparse_onlydown.pl root  #{dir+@job.name}_rwt.txt > #{dir+@job.name}_down.txt`

     `sort -k3,3n #{dir+@job.name}_down.txt | awk -f #{path_dir}dirty_reweight.awk #{dir+@job.name}_rwt.txt - > #{dir+@job.name}_cum.txt`
    `#{path_dir}apomorphy_andtable_test_statistic_cox.pl #{dir+@job.name}_rwt.txt  #{dir+@job.name}_cum.txt > #{dir+@job.name}_stat.txt`

      file =  File.open( dir+@job.name+"_stat.txt").read
      @outputfile = InputFile.new(:job_id =>@job.id, :type=>'out',:name => @job.name+"_stat.txt",  :data => file)
      @outputfile.save
  
      @results = `./mock_script.sh`
      @job.standard_output = @results
      @job.status = "complete"
      @job.save
    end

    redirect_to "/phen_gen/list"
    
  end

  def get_file
    @file = InputFile.find(params[:id])
  	send_data @file.data, :filename => @file.name #, :type => "chemical/seq-aa-fasta"
  end

  def about

  end

  def contact

  end
end
