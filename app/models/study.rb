class Study < ActiveRecord::Base
  # validates_presence_of :user_id, :name

  def bind(params)
    self.name=params["name"]
    self.description=params["description"]
    self.is_public=params["public"]
    self.pathogens =serilize_array( params[:pathogen])
    self.hosts =serilize_array( params[:hosts])
    self.locations =serilize_array( params[:locations])
    self.proteins =serilize_array( params[:protein])
  end

  def get_sql
    sql="SELECT * FROM gisbank.sequences n, gisbank.ncbi_isolate ni
WHERE ni.ncbi_isolate_id=n.ncbi_isolate_id "
    if(pathogens)
      sql<< "and pathogen_id in(#{pathogens})"
    end
    if(hosts)
      sql<< "and host_id in(#{hosts})"
    end
    if(locations)
      sql<< "and location_id in(#{locations})"
    end
    if(proteins)
      sql<< "and protein_id in(#{proteins})"
    end

    return sql
  end

  def get_sequence
    return Sequence.find_by_sql(get_sql)
  end


  private
  def serilize_array(arr)
    if(arr)
      output =''
      arr.each do |a|
        output << a +','
      end
      return output[0,output.length-1]
    else return nil
    end
  end
end