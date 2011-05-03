class Query < ActiveRecord::Base
  # validates_presence_of :user_id, :name

  def bind(params)
    self.name=params["name"]
    self.description=params["description"]
    self.is_public=params["public"]
    self.min_collect_date=DateTime.parse( params["start_date"]['year']+"-"+params["start_date"]['month']+"-"+params["start_date"]['day'])
    self.max_collect_date=DateTime.parse(params["end_date"]['year']+"-"+params["end_date"]['month']+"-"+params["end_date"]['day'])
   
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
locations.country+'/'+locations.local as location_name,
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
    	fasta << ">#{seq[:accession]}\n#{seq[:data].gsub('-','')}\n"
    end
    return fasta
 end

def make_trim_fasta

  sequences = get_sequence
  trim_cut_max = trim( sequences.max{|x| (x && x[:data]) ? x[:data].length : 0}[:data]).length
  #trim_cut_max = sequences.max{|x|  (x && x[:data]) ? x[:data].length : 0 }[:data].length
  #trim_cut_max = sequences.map{|x|  (x && x[:data]) ? trim(x[:data]).length : 0 }.max
  fasta =""

   sequences.each do |seq|
     #old code  fasta << ">#{seq[:accession]}\n#{seq[:data].gsub(/ |\r|\n/,'')[/ATG.*\z/][/^.{3}+?(TAA|TAG|TGA)/]}\n"

    trim_seq =  trim(seq[:data]);
    fasta << ">#{seq[:accession]}\n#{ (trim_seq.length+30< trim_cut_max)?seq[:data]: trim_seq }\n"

    #fasta << ">#{seq[:accession]}\n#{  trim(seq[:data]) }\n"
    end
    return fasta
end

def trim seq
    #algo_one   seq[/ATG.*\z/mx][/^.{3}+?(TAA|TAG|TGA)/mx]
    #return seq[/ATG.*(TAA|TAG|TGA)/mx]
    #return seq.gsub(/ |\r|\n/,'')[/ATG.*\z/][/\A.{3}+?(TAA|TAG|TGA)/]
    #return seq.gsub(/ |\r|\n/,'')[/ATG(A|T|G|C){3}+(TAA|TAG|TGA)/]
    return seq.gsub(/ |\r|\n/,'')[/ATG(A|T|G|C){3}+(TAA|TAG|TGA)/] #best one yet

    #s1 =  seq.gsub(/\s|\r|\n/,'')[/ATG.{3}*\z/mx][/\A.{3}+?(TAA|TAG|TGA)/mx]
    #s2 =  seq.gsub(/\s|\r|\n/,'')[/ATG..{3}*\z/mx][/\A.{3}+?(TAA|TAG|TGA)/mx]
    #s3 =  seq.gsub(/\s|\r|\n/,'')[/ATG...{3}*\z/mx][/\A.{3}+?(TAA|TAG|TGA)/mx]
   #return  [s1, s2, s3].max{|x| x ? x.length : 0}

end

# class String
#   def capitalize_each
#     self.split(" ").each{|word| word.capitalize!}.join(" ")
#   end
#   def capitalize_each!
#     replace capitalize_each
#   end
# end

def make_geo
  geodata = "strain_name,latitude,longitude,date\n"
  get_sequence.each do |seq|

         geodata << "#{seq[:accession]},#{seq[:latitude]},#{seq[:longitude]},#{format_date(seq[:date])}\n"
  end
  return geodata
end

def make_kml
  kml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<kml xmlns=\"http://earth.google.com/kml/2.2\">\n\t<Document>\n"
  kml << "\t\t<name>#{self.name}</name><open>1</open>\n"
  kml << "\t\t<description>#{self.description}</description>\n"

  get_sequence.each do |seq|
           kml << "\t\t\t<Placemark>\n\t\t\t\t<name>#{seq[:accession]}</name>\n"
           kml << " \t\t\t\t<Style><IconStyle><Icon><href>http://maps.google.com/mapfiles/kml/pushpin/wht-pushpin.png</href></Icon></IconStyle></Style>\n"
           kml << "\t\t\t\t<TimeStamp><when>#{format_date(seq[:date])}</when></TimeStamp>\n"
           kml << "\t\t\t\t<Point><coordinates>#{seq[:longitude]},#{seq[:latitude]}</coordinates> </Point> </Placemark>\n"
  end
  kml << "\t</Document>\n</kml>"
  return kml
end

def make_metadata
    meta_data = "strain_name,virus type,host,location,date\n"
    get_sequence.each do |seq|
        meta_data << "#{seq[:accession]},#{seq[:subtype]},#{seq[:host]},#{seq[:country]},#{format_date(seq[:date])}\n"
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
    year=dt[0,4]
    month=dt[5,2]=="00" ? "06" : dt[5,2]
    day=dt[8,2] =="00" ? "01" : dt[8,2]

    return "#{year}-#{month}-#{day}"
#    values = Time.parse(dt)
#    d = Time.local(*values)
#    if(d.strftime("%d") =='00' || d.strftime("%m") =='00' )
#      return d.strftime("%Y-06-01")
#    else
#      return d.strftime("%Y-%m-%d")
#    end

  end
end