class Query < ActiveRecord::Base
  belongs_to  			:user
  validates_presence_of :user_id, :name
  serialize   			:locations, Array
  serialize   			:hosts, Array
  serialize				:proteins, Array

  def validate
  	if min_collect_date.blank? and not max_collect_date.blank? or max_collect_date.blank? and not min_collect_date.blank?
  	  errors.add :min_collect_date, "Both dates must be set to use date range"
  	end
  end

  def self.form_values
    form_hash = {}

    form_hash[:types] = ['-ALL-', 'A / H1N1', 'A / H5N1']

    #form_hash[:lineages] = {'-ALL-'=>'-ALL-', 'Pandemic'=>'Y', 'Seasonal'=>'N'}
    form_hash[:lineages] = {'-ALL-'=>'-ALL-', 'Pandemic'=>'Pandemic', 'Seasonal'=>'Seasonal'}
    arr = []
    Isolate.find(:all, :select  => 'Distinct pathogen').each do |iso|
       arr << iso[:pathogen]
    end
    form_hash[:pathogen] = arr


    arr = ['-ALL-']
	Isolate.find(:all, :select => 'Distinct host', :order => "host").each do |iso|
	    arr << iso[:host] unless iso[:host].blank?
	end
	form_hash[:hosts] = arr

    arr = ['-ALL-']
	Isolate.find(:all, :select => 'Distinct location', :order => "location").each do |iso|
	  arr << iso[:location] unless iso[:location].blank?
	end
	form_hash[:locations] = arr

    form_hash[:proteins] = ['-ALL-','HA', 'NA', 'PB1', 'PB2', 'PA', 'NP', 'MP', 'NS']

    return form_hash
  end

  def new_values(params)


  	selected_hash = {}
    selected_hash[:types] = params ? params[:query][:virus_type] : "-ALL-"
    selected_hash[:lineages] = params ? params[:query][:h1n1_swine_set] : "-ALL-"
    selected_hash[:hosts] = params ? params[:query][:hosts] : "-ALL-"
    selected_hash[:locations] = params ? params[:query][:locations] : "-ALL-"
    selected_hash[:proteins] = params ? params[:query][:proteins] : "-ALL-"
    selected_hash[:pathogen] = params ? params[:query][:pathogen] : "-ALL-"

    selected_hash[:is_public] =  params ? params[:query][:is_public] : 0

    return selected_hash
  end

  def edit_values(params)
  	selected_hash = {}
    selected_hash[:types] = params ? params[:query][:virus_type] : self.virus_type
    selected_hash[:lineages] = params ? params[:query][:h1n1_swine_set] : self.h1n1_swine_set
    selected_hash[:hosts] = params ? params[:query][:hosts] : self.hosts
    selected_hash[:locations] = params ? params[:query][:locations] : self.locations
    selected_hash[:proteins] = params ? params[:query][:proteins] : self.proteins
    return selected_hash
  end

  def sequences(params)
    @sequences ||= find_sequences(params)
  end

  def make_fasta
  	fasta = ""
    sequences(nil).each do |seq|
   	  if seq[:sequence_id] and seq[:data]
    	fasta << ">#{seq[:sequence_id]}\n#{seq[:data]}\n"
      elsif seq[:genbank_acc_id] and seq[:data]
    	fasta << ">#{seq[:genbank_acc_id]}\n#{seq[:data]}\n"
      end
    end
    return fasta
  end

  def make_metadata
    metadata = "strain_name,latitude,longitude,date\n"
    sequences(nil).each do |seq|
      if seq[:sequence_id] and seq[:latitude] and seq[:longitude] and seq[:collect_date]
        metadata << "#{seq[:sequence_id]},#{seq[:latitude]},#{seq[:longitude]},#{format_date(seq[:collect_date].to_s)}\n"
      elsif seq[:genbank_acc_id] and seq[:latitude] and seq[:longitude] and seq[:collect_date]
        metadata << "#{seq[:genbank_acc_id]},#{seq[:latitude]},#{seq[:longitude]},#{format_date(seq[:collect_date].to_s)}\n"
      end
    end
    return metadata
  end

  def make_strain
  	strain = ""
    sequences(nil).each do |seq|
      if seq[:sequence_id] and seq[:sequence_type] and seq[:name] and seq[:host] and seq[:location] and seq[:h1n1_swine_set]
        strain << "#{seq[:sequence_id]},#{seq[:sequence_type]},#{seq[:name]},#{seq[:host]},#{seq[:location]},#{seq[:h1n1_swine_set]}\n"
      elsif seq[:genbank_acc_id] and seq[:sequence_type] and seq[:name] and seq[:host] and seq[:location] and seq[:h1n1_swine_set]
        strain << "#{seq[:genbank_acc_id]},#{seq[:sequence_type]},#{seq[:name]},#{seq[:host]},#{seq[:location]},#{seq[:h1n1_swine_set]}\n"
      end
    end
    return strain
  end

  private

  def find_sequences(params)
    if params
      return Sequence.paginate(:page => params[:page], :order => "isolates.name ASC",
    	:joins => :isolate,
    	:select => "isolates.pathogen, sequences.genbank_acc_id, isolates.collect_date, sequences.sequence_type, isolates.name, isolates.host, isolates.location, isolates.h1n1_swine_set",
    	:conditions => conditions)
    else
      return Sequence.find(:all, :order => "isolates.name ASC",
    	:joins => :isolate,
    	:select => "sequences.sequence_id, sequences.genbank_acc_id, sequences.data, isolates.latitude, isolates.longitude, isolates.collect_date, sequences.sequence_type, isolates.name, isolates.host, isolates.location, isolates.h1n1_swine_set",
    	:conditions => conditions)
    end
  end

  def conditions
  	cond_hash = {}
  	cond_hash["isolates.virus_type"] = virus_type if virus_type != '-ALL-'
  	cond_hash["isolates.h1n1_swine_set"] = h1n1_swine_set if h1n1_swine_set != '-ALL-'
  	cond_hash["isolates.location"] = locations if locations != ['-ALL-']
  	cond_hash["isolates.host"] = hosts if hosts != ['-ALL-']
  	cond_hash["sequences.sequence_type"] = proteins if proteins != ['-ALL-']
  	cond_hash["isolates.collect_date"] = min_collect_date..max_collect_date unless min_collect_date.blank? or max_collect_date.blank?
  	return cond_hash
  end

  def format_date(dt)
    values = Time.parse(dt)
    d = Time.local(*values)
    return d.strftime("%Y-%m-%d")
  end
end
