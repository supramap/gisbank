class QueriesController < ApplicationController
  before_filter :require_user

  # GET /queries/1
  # GET /queries/1.xml
  def show
    @query = Query.find(params[:id])
    @sequences = @query.sequences
  end

  # GET /queries/new
  # GET /queries/new.xml
  def new
    @query = Query.new

    @types = ['-ALL-', 'A / H1N1']

    @lineages = {'-ALL-'=>'-ALL-', 'Pandemic'=>'Y', 'Seasonal'=>'N'}

    @hosts = ['-ALL-']
    Isolate.find(:all, :select => 'Distinct host', :order => "host").each { |it|
        @hosts << it.host if it.host != nil
    }

    @locations = ['-ALL-']
    Isolate.find(:all, :select => 'Distinct location', :order => "location").each { |it|
        @locations << it.location if it.location != nil
    }

    @proteins = ['-ALL-','HA', 'NA', 'PB1', 'PB2', 'PA', 'NP', 'MP', 'NS']
  end

  # GET /queries/1/edit
  def edit
    @query = Query.find(params[:id])

    @types = ['-ALL-', 'A / H1N1']

    @lineages = {'-ALL-'=>'-ALL-', 'Pandemic'=>'Y', 'Seasonal'=>'N'}

    @hosts = ['-ALL-']
    Isolate.find(:all, :select => 'Distinct host', :order => "host").each { |it|
        @hosts << it.host if it.host != nil
    }

    @locations = ['-ALL-']
    Isolate.find(:all, :select => 'Distinct location', :order => "location").each { |it|
        @locations << it.location if it.location != nil
    }

    @proteins = ['-ALL-','HA', 'NA', 'PB1', 'PB2', 'PA', 'NP', 'MP', 'NS']
  end

  # POST /queries
  # POST /queries.xml
  def create
    @query = Query.new(params[:query])

    respond_to do |format|
      @seqs = @query.sequences
      if (@seqs.empty?)
        flash[:notice] = "No results found."
        format.html { redirect_to :action => "new", :id => @query.project_id }
      else
        if(@seqs.length > 100000)
          flash[:notice] = "Query too large, please narrow search parameters as necessary"
          format.html { redirect_to :action => "new", :id => @query.project_id }
        else
          if @query.save
            @folder = Createfile.file_prep(session[:user_id],@query.project_id,@query.id)
			Createfile.make_fasta(@folder,@seqs)
			Createfile.make_csv(@folder,@seqs)
			Createfile.make_strain(@folder,@seqs)
            flash[:notice] = 'Query was successfully created.'
            format.html { redirect_to(@query) }
            format.xml  { render :xml => @query, :status => :created, :location => @query }
          else
            flash[:errors] = @query.errors
            format.html { redirect_to :action => "new", :id => @query.project_id }
          end
        end
      end
    end
  end

  # PUT /queries/1
  # PUT /queries/1.xml
  def update
    @query = Query.find(params[:id])

    respond_to do |format|
      if @query.update_attributes(params[:query])
        @folder = Createfile.file_prep(session[:user_id],@query.project_id,@query.id)
        @seqs = @query.sequences
        Createfile.make_fasta(@folder,@seqs)
        Createfile.make_csv(@folder,@seqs)
        Createfile.make_strain(@folder,@seqs)
        flash[:notice] = 'Query was successfully updated.'
        format.html { redirect_to(@query) }
        format.xml  { head :ok }
      else
        flash[:errors] = @query.errors
        format.html { redirect_to(@query) }
      end
    end
  end

  # DELETE /queries/1
  # DELETE /queries/1.xml
  def destroy
    @query = Query.find(params[:id])
    Createfile.file_prep(session[:user_id],@query.project_id,@query.id)
    @query.destroy

    respond_to do |format|
      format.html { redirect_to :back }
      format.xml  { head :ok }
    end
  end
end
