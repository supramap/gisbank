class Query < ActiveRecord::Base
  belongs_to  			:project
  validates_presence_of :project_id, :name
  serialize   			:location, Array
  serialize   			:host, Array
  serialize				:protein, Array

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
        csv << "#{seq[:sequence_id]},#{seq[:latitude]},#{seq[:longitude]},#{format_date(seq[:collect_date].to_s)}\n"
      end
	  if seq[:genbank_acc_id] and seq[:latitude] and seq[:longitude] and seq[:collect_date]
        csv << "#{seq[:genbank_acc_id]},#{seq[:latitude]},#{seq[:longitude]},#{format_date(seq[:collect_date].to_s)}\n"
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
      return Sequence.paginate(:page => params[:page], :order => "isolates.name DESC",
    	:joins => :isolate,
    	:select => "sequences.sequence_id, sequences.genbank_acc_id, sequences.data, isolates.latitude, isolates.longitude, isolates.collect_date, sequences.sequence_type, isolates.name, isolates.host, isolates.location, isolates.h1n1_swine_set",
    	:conditions => conditions)
    else
      return Sequence.find(:all,:order => "isolates.name DESC",
    	:joins => :isolate,
    	:select => "sequences.sequence_id, sequences.genbank_acc_id, sequences.data, isolates.latitude, isolates.longitude, isolates.collect_date, sequences.sequence_type, isolates.name, isolates.host, isolates.location, isolates.h1n1_swine_set",
    	:conditions => conditions)
    end
  end

  def conditions
  	cond_hash = {}
  	cond_hash["isolates.virus_type"] = virus_type if virus_type != '-ALL-'
  	cond_hash["isolates.h1n1_swine_set"] = h1n1_swine_set if h1n1_swine_set != '-ALL-'
  	cond_hash["isolates.location"] = location if location != ['-ALL-']
  	cond_hash["isolates.host"] = host if host != ['-ALL-']
  	cond_hash["sequences.sequence_type"] = protein if protein != ['-ALL-']
  	cond_hash["isolates.collect_date"] = min_collect_date..max_collect_date unless min_collect_date.blank? or max_collect_date.blank?
  	return cond_hash
  end

  def format_date(dt)
    values = Time.parse(dt)
    d = Time.local(*values)
    return d.strftime("%Y-%m-%d")
  end
end
