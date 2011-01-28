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
      dir="#{RAILS_ROOT}/tmp/#{@job.id}/"
      `mkdir #{RAILS_ROOT}/tmp/#{@job.id}`
      File.open(dir+@fasta_file.name, 'w') {|f| f.write(@fasta_file.data) }
      File.open(dir+@tree_file.name, 'w') {|f|  f.write(@tree_file.data ) }
      `cat #{dir+@tree_file.name} #{dir+@fasta_file.name} | #{RAILS_ROOT}/back_end_scripts/add_tree.pl > #{dir+@job.name}_output.xml`
      `#{RAILS_ROOT}/back_end_scripts/parse_xml.rb #{dir+@job.name}_output.xml> #{dir+@job.name}_parsed.txt`
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
