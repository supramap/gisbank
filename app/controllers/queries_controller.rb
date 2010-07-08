class QueriesController < ApplicationController
  before_filter :require_user

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

    @types = ['-ALL-', 'A / H1N1', 'A / H5N1']

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

    @types = ['-ALL-', 'A / H1N1', 'A / H5N1']

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
    #@query.write_files

    respond_to do |format|
      if @query.save
        flash[:notice] = 'Query was successfully created.'
        format.html { redirect_to(@query) }
        format.xml  { render :xml => @query, :status => :created, :location => @query }
      else
		@types = ['-ALL-', 'A / H1N1', 'A / H5N1']

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

        format.html { render :action => "new" }
        format.xml  { render :xml => @query.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /queries/1
  # PUT /queries/1.xml
  def update
    @query = Query.find(params[:id])
    @query.update_attributes(params[:query])
    #@query.write_files

    respond_to do |format|
      if @query.save
        flash[:notice] = 'Query was successfully updated.'
        format.html { redirect_to(@query) }
        format.xml  { head :ok }
      else
		@types = ['-ALL-', 'A / H1N1', 'A / H5N1']

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
      format.html { redirect_to(project_url(@query.project_id)) }
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
