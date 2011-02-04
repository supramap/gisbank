class Study < ActiveRecord::Base
  # validates_presence_of :user_id, :name

  def bind(params)
    #self.name=params["name"]
    self.description=params["description"]
    self.is_public=params["public"]
    self.min_collect_date=DateTime.parse( params["start_date"]['month']+"/"+params["start_date"]['day']+"/"+params["start_date"]['year'])
    self.max_collect_date=DateTime.parse(params["end_date"]['month']+"/"+params["end_date"]['day']+"/"+params["end_date"]['year'])
   
    self.pathogens =serilize_array( params[:pathogen])
    self.hosts =serilize_array( params[:hosts])
    self.locations =serilize_array( params[:locations])
    self.proteins =serilize_array( params[:protein])
  end


  def has_pathogen(id)
    if(!self.pathogens)
      return false
    end
    return self.pathogens.split(',').include?(id.to_s)
  end

  def has_hosts(id)
    if(!self.hosts)
      return false
    end
    return self.hosts.split(',').include?(id.to_s)
  end

  def has_locations(id)
    if(!self.locations)
      return false
    end
    return self.locations.split(',').include?(id.to_s)
  end

  def has_proteins(id)
    if(!self.proteins)
      return false
    end
    return self.proteins.split(',').include?(id.to_s)
  end

  def has_pathogen(id)
    if(!self.pathogens)
      return false
    end
    return self.pathogens.split(',').include?(id.to_s)
  end


  def get_sql
    self.sql="SELECT sequences.*,
pathogen_id,
host_id,
location_id,
hosts.name as host,
proteins.name as protein,
pathogens.name as subtype,
country,
date,
virus_name,
locations.name as location_name,
longitude,
latitude
FROM sequences, isolates,locations,hosts,pathogens,proteins
WHERE isolate_id=isolates.id and location_id =locations.id and host_id=hosts.id and pathogen_id = pathogens.id and  protein_id = proteins.id
and date > '#{min_collect_date}'
and date < '#{max_collect_date}'"
    if(pathogens)
      sql<< " and pathogen_id in(#{pathogens})"
    end
    if(hosts)
      sql<< " and host_id in(#{hosts})"
    end
    if(locations)
      sql<< " and location_id in(#{locations})"
    end
    if(proteins)
      sql<< " and protein_id in(#{proteins})"
    end
    self.save;
    return self.sql
  end

  def get_sequence
    #Sequence.
    return Sequence.find_by_sql(get_sql)
  end

 def make_fasta
  	fasta = ""
    get_sequence.each do |seq|
    	fasta << ">#{seq[:accession]}\n#{seq[:data]}\n"
    end
    return fasta
  end

def make_geo
  geodata = "strain_name,latitude,longitude,date\n"
  get_sequence.each do |seq|

         geodata << "#{seq[:accession]},#{seq[:latitude]},#{seq[:longitude]},#{seq[:date]}\n"
  end
  return geodata
end

def make_metadata
    meta_data = "strain_name,virus type,host,location,date\n"
    get_sequence.each do |seq|
        meta_data << "#{seq[:accession]},#{seq[:subtype]},#{seq[:host]},#{seq[:country]},#{seq[:date]}\n"
    end
    return meta_data
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

  def format_date(dt)
    values = Time.parse(dt)
    d = Time.local(*values)
    return d.strftime("%Y-%m-%d")
  end
end