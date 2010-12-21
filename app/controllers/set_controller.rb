class SetController < ApplicationController
before_filter :require_user

  def public_queries
    @queries = Study.find_by_sql("select * from studies where is_public = 1")
  end

  def private_queries
  	 @queries = Study.find_by_sql("select * from studies where user_id = #{current_user.id}")
  end

  def new
  end

  def edit
    @query = Study.find(params[:id])
  end

  def create
    @study = Study.new
    @study.user_id=current_user.id
    @study.name=params["name"]
    @study.bind(params)

   huh= @study.save
    redirect_to :action => "show", :id => @study.id
  end

  def update
    @study = Study.find(params[:id])
    @study.bind(params)

    @study.save
    redirect_to :action => "show", :id => @study.id
  end

  def show
       @query = Study.find(params[:id])
       @seq = Sequence.paginate_by_sql(@query.get_sql,:page => params[:page], :order => 'id DESC')


       #@seq = @query.get_sequence

    if(@query.kml_status ==1 &&  Poy_service.is_done_yet(@query.job_id))
       @query.kml_status =2
       @query.save
    end
  end

  def delete
       @query = Study.find(params[:id])

       if(@query.kml_status != 0)
        Poy_service.delete(@query.job_id)
       end
       @query.destroy
     redirect_to :action => "private_queries"
  end

  def download_fasta
    @query = Study.find(params[:id])
  	send_data @query.make_fasta, :filename => "#{@query.name}.fasta", :type => "chemical/seq-aa-fasta"
  end

  def download_meta_geo_refs
       @query = Study.find(params[:id])
  	send_data @query.make_geo, :filename => "#{@query.name}.fasta", :type => "chemical/seq-aa-fasta"
  end

  def download_metadata
       @query = Study.find(params[:id])
  	send_data @query.make_metadata, :filename => "#{@query.name}.fasta", :type => "chemical/seq-aa-fasta"
  end

   def start_poy
    @job_id = Poy_service.init
    @query = Study.find(params[:id])\

    # if 100 limit the total / 2 times will max at 83 hours
    # if 300 limit the total / 20 times will max at 75 hours
    # if 500 limit the total / 50 times will max at 83 hours
    total =  @query.get_sequence.length;
    @total_minutes = ((total * total )/20 ).ceil+3
    @search_minutes= ((total * total )/60).ceil+1
    Poy_service.add_text_file(@job_id,"#{@query.name}.fasta", @query.make_fasta)

    Poy_service.add_text_file(@job_id,"#{@query.name}.csv", @query.make_geo)
    Poy_service.add_poy_file(@job_id,"#{@query.name}",@search_minutes)

     results = Poy_service.submit_poy(@job_id,@total_minutes )

     if(results=="Success")

     @query.kml_status =1
     @query.job_id = @job_id
     @query.save
    else
      flash[:notice] = "Failed to submit poy:#{results}"
    end

    redirect_to :action => "show", :id => params[:id]
  end


  def download_supramap_kml

    @query = Study.find(params[:id])
    @fileString = Poy_service.get_file(@query.job_id,"results.kml")
    send_data @fileString, :filename => "results.kml"

    end

    def download_supramap_output

    @query = Study.find(params[:id])
    @fileString = Poy_service.get_file(@query.job_id,"output.txt")
    send_data @fileString, :filename => "output.txt"

    end

   def download_aligned_fasta

    @query = Study.find(params[:id])
    @fileString = Poy_service.get_file(@query.job_id,"alignment.fas")
    send_data @fileString, :filename => "alignment.fas"

    end

end
