class PoyController < ApplicationController

  def new
     @query = Query2.find(params[:id])
     #@seq =
    @job = PoyJob.new
  end

  def create
    @query = Query2.find(params[:id])
    @job = PoyJob.new(params[:job])
    @job.outgroup = params[:outgroup]
    @job.resource = params[:resource]

    @job.query_id = @query.id
    if(params[:trimed] == "1")
      @job.fasta= @query.make_trim_fasta
    else
      @job.fasta= @query.make_fasta
    end

    @job.geo = @query.make_geo
    @job.addpoyfile(@query.name,@query.get_sequence.length)
    @job.save
    @job.submit
    redirect_to :controller=> "set", :action => "show", :id => params[:id]
  end

  def download_supramap_kml
    @poyjob = PoyJob.find(params[:id])
      send_data @poyjob.kml, :filename => "#{Query2.find(@poyjob.query_id).name}.kml", :type => "kml", :disposition => 'attachment'
  end

  def download_output
    @poyjob = PoyJob.find(params[:id])
    data_string = @poyjob.output
     send_data data_string, :filename => "#{Query2.find(@poyjob.query_id).name}_output.txt" , :type => "txt", :disposition => 'attachment'
  end

  def download_aligned_fasta
    @poyjob = PoyJob.find(params[:id])
    send_data @poyjob.aligned_fasta, :filename => "#{Query2.find(@poyjob.query_id).name}.ia", :type => "ia", :disposition => 'attachment'
  end

  def download_tree
    @poyjob = PoyJob.find(params[:id])
    send_data @poyjob.tree, :filename => "#{Query2.find(@poyjob.query_id).name}.tre", :type => "tre", :disposition => 'attachment'
  end

   def download_poy_script
    @poyjob = PoyJob.find(params[:id])
    send_data @poyjob.poy, :filename => "#{Query2.find(@poyjob.query_id).name}_poy.txt", :type => "txt", :disposition => 'attachment'
   end

   def download_poy_output
    @poyjob = PoyJob.find(params[:id])
    send_data @poyjob.poy_output, :filename => "#{Query2.find(@poyjob.query_id).name}_output.txt", :type => "txt", :disposition => 'attachment'
   end

end
