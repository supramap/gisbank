class InputFileController < ApplicationController
  def new
    render :inline =>
  "xml.p {'Horrid coding practice!'}", :layout => false #,:type => :builder
  end

  def create
     if(JobFile.where("file_type = 'fas' and job_id=#{params[:id]}").length>1)
      render :text => "{success:false}"
    end

    file_data =request.raw_post
    @fasta_file = JobFile.new(:job_id =>params[:id], :file_type=>'fas', :name => params[:qqfile] ,  :data =>  file_data)
    @fasta_file.save
    render :text => "{success:true}"

  end

  def show
  end

  def delete
  end

end
