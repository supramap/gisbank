class SetController < ApplicationController

  def new
    #@form_values = Query.form_values
   # @query = Query.new
    #@sql_query = SqlQuery.new
	  @form_values = Query.form_values
	 # @selected_values = @query.new_values(nil)
  end

  def create
    current_user = UserSession.find
    id = current_user && current_user.record.id
       @items = params
      @set =  SqlQuery.create(id, @items)
      @set.save
       #redirect_to :action => "show", :id => @set.sql_queries_id
       redirect_to @set
  end

  def show
       # @query = SqlQuery.find(params[:id])
        @query = SqlQuery.find(params[:sql_queries_id])
        @sequences = @query.get_sequences()


    if(@query.kml_status ==1 &&  Poy_service.is_done_yet(@query.job_id))
       @query.kml_status =2
       @query.save
    end
  end

end
