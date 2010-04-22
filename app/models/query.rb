class Query < ActiveRecord::Base
  belongs_to  			:project
  validates_presence_of :project_id, :name
  serialize   			:virus_type, Array
  serialize   			:lineage, Array
  serialize   			:location, Array
  serialize   			:host, Array

  def sequences
    @sequences ||= find_sequences 
  end

  def types
  	sequences = []
    sequences << 'HA' if ha == true
	sequences << 'NA' if na == true
	sequences << 'PB1' if pb1 == true
	sequences << 'PB2' if pb2 == true
	sequences << 'PA' if pa == true
	sequences << 'NP' if np == true
	sequences << 'MP' if mp == true
	sequences << 'NS' if ns == true
	@types = sequences
  end

  private

  def find_sequences
    Sequence.find(:all, :joins => :isolate, :conditions => conditions)
  end

  def isolate_name_conditions
    ["isolates.name LIKE ?", "%#{isolate_name}%"] unless isolate_name.blank?
  end

  def virus_type_conditions
    ["isolates.virus_type IN (?)", virus_type] unless virus_type == ['-ALL-']
  end

  def h1n1_swine_set_conditions
    ["isolates.h1n1_swine_set LIKE ?", "%#{h1n1_swine_set}%"] unless h1n1_swine_set == ['-ALL-']
  end

  def location_conditions
    ["isolates.location IN (?)", location] unless location == ['-ALL-']
  end

  def host_conditions
    ["isolates.host IN (?)", host] unless host == ['-ALL-']
  end

  def collect_date_conditions
    ["isolates.collect_date BETWEEN ? AND ?", min_collect_date, max_collect_date] unless min_collect_date.blank? or max_collect_date.blank?
  end

  def sequence_type_conditions
	["sequences.sequence_type IN (?)", types] unless types.empty?
  end

  def conditions
    [conditions_clauses.join(' AND '), *conditions_options]
  end

  def conditions_clauses
    conditions_parts.map { |condition| condition.first }
  end

  def conditions_options
    conditions_parts.map { |condition| condition[1..-1] }.flatten
  end

  def conditions_parts
    private_methods(false).grep(/_conditions$/).map { |m| send(m) }.compact
  end
end
