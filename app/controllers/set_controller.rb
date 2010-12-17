class SetController < ApplicationController

  def new
 
  end

  def create
    current_user = UserSession.find
    #@study = Study.new(params)
    @study = Study.new
    @study.user_id=current_user.id
    @study.bind(params)
    #@study.location = Study.
   huh= @study.save
  
    redirect_to :action => "show", :id => @study.id
      
  end

  def show
     
        @query = Study.find(params[:id])

    if(@query.kml_status ==1 &&  Poy_service.is_done_yet(@query.job_id))
       @query.kml_status =2
       @query.save
    end
  end

end
