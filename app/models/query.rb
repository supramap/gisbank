class Query < ActiveRecord::Base
  belongs_to  			:project
  validates_presence_of :project_id, :name
  serialize   			:location, Array
  serialize   			:host, Array
  serialize				:protein, Array

  def sequences
    @sequences ||= find_sequences
  end

  private

  def find_sequences
    Sequence.find(:all,
    	:joins => :isolate,
    	:select => "sequences.sequence_id, sequences.genbank_acc_id, sequences.data, isolates.latitude, isolates.longitude, isolates.collect_date, sequences.sequence_type, isolates.name, isolates.host, isolates.location, isolates.h1n1_swine_set",
    	:conditions => conditions)
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
end
