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
    @job = Job.new(:name => params[:job][:name],:outgroup => params[:job][:outgroup], :prealigned_fasta => params[:is_prealigned],  :supplied_tree=> params[:use_tree],:user_id => current_user.id , :status => "queued" )
    @job.save

    file =  File.open(params[:job][:fasta_file].tempfile.path).read
    @fasta_file = JobFile.new(:job_id =>@job.id, :file_type=>'fas', :name => params[:job][:fasta_file].original_filename,  :data => file)
    @fasta_file.save

    if(params[:use_tree]=="1")
        file =  File.open(params[:job][:tree_file].tempfile.path).read
        @tree_file = JobFile.new(:job_id =>@job.id, :file_type=>'tre',:name => params[:job][:tree_file].original_filename,  :data => file)
        @tree_file.save
      #else
    end
    #@poy = Poy.new(@job)
    spawn(:method => :thread,:argv => 'phengen_job') do
      @poy = Poy.new(@job)
      @job.start
    end
    redirect_to "/phen_gen/list"
    
  end

  def debug
    Job.find(params[:id]).start
    redirect_to "/phen_gen/list"
  end

  def debug_poy
    #Poy.new(Job.find(params[:id]))
    @job = Job.find(params[:id])
    poy_output = PoyService.get_file(@job.service_id,"#{@job.name}.poy_output")
    JobFile.new(:job_id => @job.id, :file_type=>"poy_out",:name => "#{@job.name}.poy_output",  :data => poy_output).save

    tree_data = PoyService.get_file(@job.service_id,"#{@job.name}.tre")
    JobFile.new(:job_id => @job.id, :file_type=>"tre",:name => "#{@job.name}.tre",  :data => tree_data).save
    redirect_to "/phen_gen/list"
  end

  def delete

    JobFile.where("job_id = ?", params[:id]).each{|a| a.destroy}
    Job.find(params[:id]).destroy
    redirect_to "/phen_gen/list"
  end



  def get_file
    @file = JobFile.find(params[:id])
  	send_data @file.data, :filename => @file.name #, :type => "chemical/seq-aa-fasta"
  end

  def about

  end

  def contact

  end
end
