class QueriesController < ApplicationController
  before_filter :require_user
  before_filter :editable, :only => [:edit, :destroy, :update]
  before_filter :viewable, :only => [:show, :download_fasta, :download_metadata, :download_strain]

  def index
  	@queries = Query.paginate(:page => params[:page])
  end

   # GET /queries/public
  # GET /queries/public.xml
   def public

  	#@queries = Query.where("is_public = 1")
    @queries = Query.find_by_sql("select * from queries where is_public = 1")

  end

  def private
  	 @queries = Query.find_by_sql("select * from queries where user_id = #{current_user.id}")

  end

  # GET /queries/1
  # GET /queries/1.xml
  def show
    @query = Query.find(params[:id])
    @sequences = @query.sequences(params)


    if(@query.kml_status ==1 &&  Poy_service.is_done_yet(@query.job_id))
       @query.kml_status =2
       @query.save
    end
  end

  def start_poy
    @job_id = Poy_service.init
    @query = Query.find(params[:id])

    #@total_minutes = ((@query.total_sequences * @query.total_sequences)/2 ).ceil+3
    #@search_minutes= ((@query.total_sequences * @query.total_sequences)/6).ceil+1
    @total_minutes = ((@query.total_sequences * @query.total_sequences)/500 ).ceil+3
    @search_minutes= ((@query.total_sequences * @query.total_sequences)/1500).ceil+1
    Poy_service.add_text_file(@job_id,"#{@query.name}.fasta", @query.make_fasta)
  
    Poy_service.add_text_file(@job_id,"#{@query.name}.csv", @query.make_metadata)
    Poy_service.add_poy_file(@job_id,"#{@query.name}",@search_minutes)
    Poy_service.submit_poy(@job_id,@total_minutes );

    @query.kml_status =1
    @query.job_id = @job_id
    @query.save

    redirect_to :action => "show", :id => params[:id]
  end

  # GET /queries/new
  # GET /queries/new.xml
  def new
    @query = Query.new
	@form_values = Query.form_values
	@selected_values = @query.new_values(nil)
  end

  # GET /queries/1/edit
  def edit
    @query = Query.find(params[:id])
	@form_values = Query.form_values
	@selected_values = @query.edit_values(nil)
  end

  # POST /queries
  # POST /queries.xml
  def create
    @query = Query.new(params[:query])

    @query.total_sequences = @query.sequences(params).total_entries

    respond_to do |format|
      if @query.save
        flash[:notice] = 'Query was successfully created.'
        format.html { redirect_to(@query) }
        format.xml  { render :xml => @query, :status => :created, :location => @query }
      else
		@form_values = Query.form_values
		@selected_values = @query.new_values(params)
        format.html { render :action => "new" }
        format.xml  { render :xml => @query.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /queries/1
  # PUT /queries/1.xml
  def update
    @query = Query.find(params[:id])
    #@query
    @query.total_sequences = @query.sequences(params).total_entries

    respond_to do |format|
      if @query.update_attributes(params[:query])
        flash[:notice] = 'Query was successfully updated.'
        format.html { redirect_to(@query) }
        format.xml  { head :ok }
      else
		@form_values = Query.form_values
		@selected_values = @query.edit_values(params)
        format.html { render :action => "edit" }
        format.xml  { render :xml => @query.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /queries/1
  # DELETE /queries/1.xml
  def destroy
    @query = Query.find(params[:id])
    @query.destroy

    respond_to do |format|
      format.html { redirect_to queries_path }
      format.xml  { head :ok }
    end
  end

  def download_fasta
  	@query = Query.find(params[:id])
  	send_data @query.make_fasta, :filename => "#{@query.name}.fasta", :type => "chemical/seq-aa-fasta"
  end

  def download_metadata
  	@query = Query.find(params[:id])
  	send_data @query.make_metadata, :filename => "#{@query.name}.csv", :type => "chemical/seq-aa-fasta"
  end

  def download_strain
  	@query = Query.find(params[:id])
  	send_data @query.make_strain, :filename => "#{@query.name}-strain.csv", :type => "chemical/seq-aa-fasta"
  end

  def download_supramap_kml
   
    @query = Query.find(params[:id])
    @fileString = Poy_service.get_file(@query.job_id,"results.kml")
    send_data @fileString, :filename => "results.kml"

    end

    def download_supramap_output

    @query = Query.find(params[:id])
    @fileString = Poy_service.get_file(@query.job_id,"output.txt")
    send_data @fileString, :filename => "output.txt"

    end

   def download_aligned_fasta

    @query = Query.find(params[:id])
    @fileString = Poy_service.get_file(@query.job_id,"alignment.fas")
    send_data @fileString, :filename => "alignment.fas"

    end

end