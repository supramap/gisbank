class PhenGenController < ApplicationController
  before_filter :require_user, :only => [:list, :new, :create]

  def home
  end
  
  def list
    @jobs = Job.where("user_id = #{current_user.id}")
  end

  def new
    @job = Job.new
    @job.save
  end
  
  def create

     @job =Job.find(params[:id])
    #@job = Job.new(:name => params[:job][:name],:outgroup => params[:job][:outgroup], :prealigned_fasta => params[:is_prealigned],  :supplied_tree=> params[:use_tree],:user_id => current_user.id , :status => "queued" )

     @job.name = params[:job][:name]
     @job.user_id = current_user.id
     @job.status = "queued"
     @job.save

     @job.prealigned_fasta = (params[:is_prealigned]=="1")

    if(params[:SelectOutGroup]=="0")
      @job.outgroup = params[:outgroup]
    else
      @job.outgroup = params[:job][:outgroup]
    end

   @job.supplied_tree = params[:use_tree]
    if(params[:use_tree]=="1")
        file =  File.open(params[:job][:tree_file].tempfile.path).read
        @tree_file = JobFile.new(:job_id =>@job.id, :file_type=>'tre',:name => params[:job][:tree_file].original_filename,  :data => file)
        @tree_file.save
    end
    @job.save

     
    #PoyRunner.run(@job)
    spawn(:method => :thread,:argv => 'phengen_job') do
      #@poy = Poy.new(@job)
      PoyRunner.run(@job)
      @job.start
    end

    redirect_to "/phen_gen/list"
    
  end

  def fasta_upload
    if(JobFile.where("file_type = 'fas' and job_id=#{params[:id]}").length>1)
      render :text => "{success:false}"
    end
    
    file_data =request.raw_post
    @fasta_file = JobFile.new(:job_id =>params[:id], :file_type=>'fas', :name => params[:qqfile] ,  :data =>  file_data)
    @fasta_file.save
    render :text => "{success:true}"
  end

  def outgroup_options
     render :json  => JobFile.where("file_type = 'fas' and job_id=#{params[:id]}")[0].data.split("\n").select{|a| a[0]=='>'}.map{|a| a[1,9999].strip}
  end

  def fasta_uploaded
    if(JobFile.where("file_type = 'fas' and job_id=#{params[:id]}")[0].count>0)
     render :json  => true
    else
    render :json  => false
    end
  end

  def debug
    Job.find(params[:id]).start
    redirect_to "/phen_gen/list"
  end

  def debug_poy
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
    #redirect_to "/phen_gen/list"
    render :nothing => true
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
