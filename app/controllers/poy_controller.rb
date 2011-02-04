class PoyController < ApplicationController

  def new
     @query = Study.find(params[:id])
     #@seq =
    @job = PoyJob.new
  end

  def create
    @query = Study.find(params[:id])
    @job = PoyJob.new(params[:job])
    @job.outgroup = params[:outgroup]
    @job.query_id = @query.id
    @job.fasta= @query.make_fasta
    @job.geo = @query.make_geo
    @job.addpoyfile(@query.name,@query.get_sequence.length)
    @job.save
    @job.submit
    redirect_to :controller=> "set", :action => "show", :id => params[:id]
  end

  def download_supramap_kml
    @poyjob = PoyJob.first(:conditions => ["query_id = ?",params[:id]])
      send_data @poyjob.kml, :filename => "#{Study.find(@poyjob.query_id).name}.kml", :type => "kml", :disposition => 'attachment'
  end

  def download_output
    @poyjob = PoyJob.first(:conditions => ["query_id = ?",params[:id]])
    data_string = @poyjob.output
     send_data data_string, :filename => "#{Study.find(@poyjob.query_id).name}_output.txt" , :type => "txt", :disposition => 'attachment'
  end

  def download_aligned_fasta
    @poyjob = PoyJob.first(:conditions => ["query_id = ?",params[:id]])
    send_data @poyjob.aligned_fasta, :filename => "#{Study.find(@poyjob.query_id).name}.ia", :type => "ia", :disposition => 'attachment'
  end

  def download_tree
    @poyjob = PoyJob.first(:conditions => ["query_id = ?",params[:id]])
    send_data @poyjob.tree, :filename => "#{Study.find(@poyjob.query_id).name}.tre", :type => "tre", :disposition => 'attachment'
  end
end
