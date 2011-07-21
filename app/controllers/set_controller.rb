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
     name = @study.name
    @study.bind(params)
     @study.name = name
    @study.save
    redirect_to :action => "show", :id => @study.id
  end

  def show
    debug = File.new('log/debug.txt', "a")

    debug.write "\n\n\nstart a show at"+  Time.now.to_s() +"\n"

    debug.flush
    logger.info 'start a show at'+  Time.now.to_s() +"\n"
    logger.flush
    @query = Query2.find(params[:id])

     logger.info "got query #{@query.name}info at"+  Time.now.to_s
     debug.write  "got query #{@query.name} info at "+  Time.now.to_s() +"\n"


    @seq = Sequence.find_by_sql(@query.get_sql)
    #@poyjobs = PoyJob.find_by_sql("SELECT * FROM gisbank.poy_jobs where query_id =#{ params[:id]}")

    logger.info 'got query results at at'+  Time.now.to_s
      debug.write  'got query results at at'+  Time.now.to_s()   +"\n"


      @poyjobs = PoyJob.find_by_sql("SELECT id, query_id, status, service_job,
case when kml is null then 0 else 1 end as iskml ,
case when aligned_fasta is null then 0 else 1 end as isaligned_fasta,
case when poy_output is null then 0 else 1 end as ispoy_output,
case when output is null then 0 else 1 end as isoutput,
case when tree is null then 0 else 1 end as istree,
case when poy is null then 0 else 1 end as ispoy
FROM gisbank.poy_jobs where query_id=#{ params[:id]}")

    logger.debug 'got poy jobs at'+  Time.now.to_s
      logger.flush
      debug.write 'got poy jobs at'+  Time.now.to_s()   +"\n"
    debug.flush
    debug.close
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
