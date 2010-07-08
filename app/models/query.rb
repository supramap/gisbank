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

  def new_values(params)
  	selected_hash = {}
    selected_hash[:types] = params ? params[:query][:type] : "-ALL-"
    selected_hash[:lineages] = params ? params[:query][:lineage] : "-ALL-"
    selected_hash[:hosts] = params ? params[:query][:hosts] : "-ALL-"
    selected_hash[:locations] = params ? params[:query][:locations] : "-ALL-"
    selected_hash[:proteins] = params ? params[:query][:proteins] : "-ALL-"
    return selected_hash
  end

  def edit_values(params)
  	selected_hash = {}
    selected_hash[:types] = params ? params[:query][:type] : self.virus_type
    selected_hash[:lineages] = params ? params[:query][:lineage] : self.h1n1_swine_set
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
      end
      if seq[:genbank_acc_id] and seq[:data]
    	fasta << ">#{seq[:genbank_acc_id]}\n#{seq[:data]}\n"
      end
    end
    return fasta
  end

  def make_metadata
    metadata = ""
    sequences(nil).each do |seq|
      if seq[:sequence_id] and seq[:latitude] and seq[:longitude] and seq[:collect_date]
        metadata << "#{seq[:sequence_id]},#{seq[:latitude]},#{seq[:longitude]},#{format_date(seq[:collect_date].to_s)}\n"
      end
	  if seq[:genbank_acc_id] and seq[:latitude] and seq[:longitude] and seq[:collect_date]
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
      end
      if seq[:genbank_acc_id] and seq[:sequence_type] and seq[:name] and seq[:host] and seq[:location] and seq[:h1n1_swine_set]
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
    	:select => "sequences.sequence_id, sequences.genbank_acc_id, sequences.data, isolates.latitude, isolates.longitude, isolates.collect_date, sequences.sequence_type, isolates.name, isolates.host, isolates.location, isolates.h1n1_swine_set",
    	:conditions => conditions)
    else
      return Sequence.find(:all,:order => "isolates.name ASC",
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
