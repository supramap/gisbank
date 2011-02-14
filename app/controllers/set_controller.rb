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
    @poyjobs = PoyJob.find_by_sql("SELECT * FROM gisbank.poy_jobs where query_id =#{ params[:id]}")
    #@poyjobs = PoyJob.all.find_all {|i|  i.query_id = params[:id]}
#    @poyjob = PoyJob.first(:conditions => ["query_id = ?",params[:id]])
#
#    if(@poyjob && @poyjob.status==1)
#      @poyjob.isdone
#    end

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
    send_data @query.make_fasta, :filename => "#{@query.name}.fasta", :type => "chemical/seq-aa-fasta", :disposition => 'attachment'
    
    #send_file @query.make_fasta, :filename => "#{@query.name}.fasta", :type => "chemical/seq-aa-fasta"

  	#org
  	#send_data @query.make_fasta, :filename => "#{@query.name}.fasta", :type => "chemical/seq-aa-fasta"
  end

  def download_meta_geo_refs
    @query = Study.find(params[:id])
  	send_data @query.make_geo, :filename => "#{@query.name}_geo.csv", :type => "csv", :disposition => 'attachment'
  end

  def download_metadata
    @query = Study.find(params[:id])
  	send_data @query.make_metadata, :filename => "#{@query.name}_meta_data.csv", :type => "csv", :disposition => 'attachment'
  end


end
