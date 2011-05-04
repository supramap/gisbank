class SetController < ApplicationController
  before_filter :require_user

  def public_queries
    @queries = Query2.find_by_sql("select * from query2s where is_public = 1")
  end

  def private_queries
    @queries = Query2.find_by_sql("select * from query2s where user_id = #{current_user.id}")
  end

  def new
  end

  def edit
    @query = Query2.find(params[:id])
  end

  def create
    @study = Query2.new
    @study.user_id=current_user.id
    @study.name=params["name"]
    @study.bind(params)

    huh= @study.save
    redirect_to :action => "show", :id => @study.id
  end

  def update
    @study = Query2.find(params[:id])
    @study.bind(params)

    @study.save
    redirect_to :action => "show", :id => @study.id
  end

  def show
    @query = Query2.find(params[:id])
    #@seq = Sequence.paginate_by_sql(@query.get_sql,:page => params[:page], :order => 'id DESC')
    @seq = Sequence.find_by_sql(@query.get_sql)
    @poyjobs = PoyJob.find_by_sql("SELECT * FROM gisbank.poy_jobs where query_id =#{ params[:id]}")
    #@poyjobs = PoyJob.all.find_all {|i|  i.query_id = params[:id]}
#    @poyjob = PoyJob.first(:conditions => ["query_id = ?",params[:id]])
#
#    if(@poyjob && @poyjob.status==1)
#      @poyjob.isdone
#    end

  end

  def delete
    @query = Query2.find(params[:id])

    if(@query.kml_status != 0)
      Poy_service.delete(@query.job_id)
    end
    @query.destroy
    redirect_to :action => "private_queries"
  end

  def download_fasta
    @query = Query2.find(params[:id])
    send_data @query.make_fasta, :filename => "#{@query.name}.fasta", :type => "chemical/seq-aa-fasta", :disposition => 'attachment'
    
    #send_file @query.make_fasta, :filename => "#{@query.name}.fasta", :type => "chemical/seq-aa-fasta"

  	#org
  	#send_data @query.make_fasta, :filename => "#{@query.name}.fasta", :type => "chemical/seq-aa-fasta"
  end

  def download_trim_fasta
     @query = Query2.find(params[:id])
     send_data @query.make_trim_fasta, :filename => "#{@query.name}.trimmed.fasta", :type => "chemical/seq-aa-fasta", :disposition => 'attachment'
  end

  def download_meta_geo_refs
    @query = Query2.find(params[:id])
  	send_data @query.make_geo, :filename => "#{@query.name}_geo.csv", :type => "csv", :disposition => 'attachment'
  end

  def download_kml
    @query = Query2.find(params[:id])
  	send_data @query.make_kml, :filename => "#{@query.name}.kml", :type => "kml", :disposition => 'attachment'
  end

  def download_metadata
    @query = Query2.find(params[:id])
  	send_data @query.make_metadata, :filename => "#{@query.name}_meta_data.csv", :type => "csv", :disposition => 'attachment'
  end


end
