class QueriesController < ApplicationController
  before_filter :require_user
  
  # GET /queries/1
  # GET /queries/1.xml
  def show
    @query = Query.find(params[:id])
    @isos = @query.isolates
  end

  # GET /queries/new
  # GET /queries/new.xml
  def new
    @query = Query.new
 
    @isolates = ['-ALL-']
    Isolate.find(:all, :select => 'name').each { |it|
      if (it.name != nil)
        @isolates << it.name
      end
    }
    @isolates.sort!
    @selected_iso = ['-ALL-']

    @types = ['-ALL-']
    Isolate.find(:all, :select => 'Distinct virus_type').each { |it|
      if (it.virus_type != nil)
        @types = @types << it.virus_type
      end
    }
    @types.sort!
    @selected_types = @types[1]
    
    @lineage_options = ['-ALL-',
                        'Pandemic',
                        'Seasonal']
    @selected_lineage = @lineage_options[1]

    @hosts = ['-ALL-']
    Isolate.find(:all, :select => 'Distinct host').each { |it|
      if (it.host != nil)
          @hosts = @hosts << it.host
      end
    }
    @hosts.sort!
    @selected_hosts = ['-ALL-']
 
    @locations = ['-ALL-']
    Isolate.find(:all, :select => 'Distinct location').each { |it|
      if (it.location != nil)
        @locations = @locations << it.location
      end
    }
    @locations.sort!
    @selected_locations = ['-ALL-']
  end

  # GET /queries/1/edit
  def edit
    @query = Query.find(params[:id])

    @types = ['-ALL-']
    Isolate.find(:all, :select => 'Distinct virus_type').each { |it|
      if (it.virus_type != nil)
        @types = @types | [it.virus_type]
      end
    }
    @types.sort!
    @selected_types = ['-ALL-']

    @lineage_options = ['-ALL-',
                        'Pandemic',
                        'Seasonal']
    @selected_lineage = @lineage_options[0]

    @hosts = ['-ALL-']
    Isolate.find(:all, :select => 'Distinct host').each { |it|
      if (it.host != nil)
          @hosts = @hosts | [it.host]
      end
    }
    @hosts.sort!
    @selected_hosts = ['-ALL-']

    @locations = ['-ALL-']
    Isolate.find(:all, :select => 'Distinct location').each { |it|
      if (it.location != nil)
        @locations = @locations | [it.location]
      end
    }
    @locations.sort!
    @selected_locations = ['-ALL-']
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
