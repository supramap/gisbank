class QueriesController < ApplicationController
  before_filter :require_user
  before_filter :editable, :only => [:edit, :destroy, :update]
  before_filter :viewable, :only => [:show, :download_fasta, :download_metadata, :download_strain]

  def index
  	@queries = Query.paginate(:page => params[:page])
  end

  # GET /queries/1
  # GET /queries/1.xml
  def show
    @query = Query.find(params[:id])
    @sequences = @query.sequences(params)
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
end
